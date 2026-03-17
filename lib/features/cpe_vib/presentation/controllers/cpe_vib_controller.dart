import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import '../../data/datasources/settings_local_datasource.dart';
import '../../data/datasources/wifi_datasource.dart';
import '../../data/repositories/cpe_vib_repository.dart';
import '../../domain/services/command_builder.dart';
import '../../domain/services/frame_parser.dart';
import 'cpe_vib_state.dart';

class CpeVibController extends ChangeNotifier {
  final CpeVibRepository _repository;
  final FrameParser _frameParser;
  final CommandBuilder _commandBuilder;

  CpeVibState _state = CpeVibState.initial();
  CpeVibState get state => _state;

  final StringBuffer _rxBuffer = StringBuffer();

  Timer? _pollTimer;
  Timer? _startTimer;
  Timer? _autoRestartTimer;
  Timer? _delaySignalTimer;

  bool _waitingProbe = false;
  bool _exitInProgress = false;

  Completer<bool>? _impostaCompleter;
  String? _pendingImpostaEcho;

  CpeVibController({
    required CpeVibRepository repository,
    required FrameParser frameParser,
    required CommandBuilder commandBuilder,
  })  : _repository = repository,
        _frameParser = frameParser,
        _commandBuilder = commandBuilder;

  factory CpeVibController.create() {
    return CpeVibController(
      repository: CpeVibRepository(
        wifiDatasource: WifiDatasource(),
        settingsDatasource: SettingsLocalDatasource(),
      ),
      frameParser: const FrameParser(),
      commandBuilder: const CommandBuilder(),
    );
  }

  Future<void> init() async {
    final settings = await _repository.loadSettings();
    _state = _state.copyWith(settings: settings);
    notifyListeners();
  }

  Future<void> disposeController() async {
    _pollTimer?.cancel();
    _startTimer?.cancel();
    _autoRestartTimer?.cancel();
    _delaySignalTimer?.cancel();
    await _repository.disconnect();
  }

  void setPageIndex(int index) {
    _state = _state.copyWith(pageIndex: index);
    notifyListeners();
  }

  void setHost(String value) {
    _state = _state.copyWith(host: value);
    notifyListeners();
  }

  void setPort(String value) {
    _state = _state.copyWith(port: value);
    notifyListeners();
  }

  void setOutgoingText(String value) {
    _state = _state.copyWith(outgoingText: value);
    notifyListeners();
  }

  void setPezzi(int value) {
    final safeValue = value.clamp(0, 999).toInt();
    _state = _state.copyWith(
      params: _state.params.copyWith(pezzi: safeValue),
    );
    notifyListeners();
  }

  void setSeOff(int value) {
    _state = _state.copyWith(
      params: _state.params.copyWith(seOff: value),
    );
    notifyListeners();
  }

  void setSeOn(int value) {
    _state = _state.copyWith(
      params: _state.params.copyWith(seOn: value),
    );
    notifyListeners();
  }

  void setVibCam(int value) {
    _state = _state.copyWith(
      params: _state.params.copyWith(vibCam: value),
    );
    notifyListeners();
  }

  void setVibTaz(int value) {
    _state = _state.copyWith(
      params: _state.params.copyWith(vibTaz: value),
    );
    notifyListeners();
  }

  void setRitCh(int value) {
    _state = _state.copyWith(
      params: _state.params.copyWith(ritCh: value),
    );
    notifyListeners();
  }

  void setFormValue(int value) {
    _state = _state.copyWith(
      params: _state.params.copyWith(formValue: value),
    );
    notifyListeners();
  }

  Future<void> toggleExpMode() async {
    final updated = _state.settings.copyWith(
      expMode: !_state.settings.expMode,
    );
    _state = _state.copyWith(settings: updated);
    notifyListeners();
    await _repository.saveSettings(updated);
  }

  Future<void> toggleSixChannelsMode() async {
    final updated = _state.settings.copyWith(
      sixChannelsMode: !_state.settings.sixChannelsMode,
    );
    _state = _state.copyWith(settings: updated);
    notifyListeners();
    await _repository.saveSettings(updated);
  }

  void setTimerValue(int value) {
    _state = _state.copyWith(timer: value);
    notifyListeners();
  }

  Future<void> connect() async {
    final host = _state.host.trim();
    final port = int.tryParse(_state.port) ?? 5000;
    final base = _deriveBaseFromHost(host);

    _addLog('WiFi: connessione ai terminali $base.101/.102/.103 ...');

    final results = await _repository.connectTerms(
      baseIp: base,
      port: port,
      onData: (terminal, data) {
        if (_state.activeTerminal == terminal) {
          onBytes(Uint8List.fromList(data));
        }
      },
      onDone: (terminal) {
        _addLog('WiFi $terminal: connessione chiusa.');
        if (_state.activeTerminal == terminal) {
          _state = _state.copyWith(isConnected: false);
          notifyListeners();
        }
      },
      onError: (terminal, error) {
        _addLog('WiFi $terminal errore: $error');
      },
      timeout: const Duration(milliseconds: 900),
    );

    final onTerms = [
      for (final e in results.entries)
        if (e.value) e.key,
    ]..sort();

    if (onTerms.isEmpty) {
      _addLog('WiFi: nessun terminale raggiungibile.');
      _state = _state.copyWith(
        isConnected: false,
        activeTerminal: null,
      );
      notifyListeners();
      return;
    }

    final active = onTerms.first;
    _repository.setActiveTerminal(active);

    _state = _state.copyWith(
      isConnected: true,
      activeTerminal: active,
    );
    _addLog('WiFi: attivo TERM-$active.');
    notifyListeners();

    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  Future<void> disconnect() async {
    try {
      await sendAscii(_commandBuilder.disconnectMachine());
      await Future.delayed(const Duration(milliseconds: 60));
      await sendAscii(_commandBuilder.disconnectMachine());
      await Future.delayed(const Duration(milliseconds: 60));
      await sendAscii(_commandBuilder.disconnectMachine());
    } catch (_) {}

    await _repository.disconnect();

    _stopConMode();
    _stopDelaySignal();

    _state = _state.copyWith(
      isConnected: false,
      activeTerminal: null,
      isAutoLoop: false,
    );
    notifyListeners();
  }

  Future<void> setActiveTerminal(int terminal) async {
    if (_repository.hasTerminal(terminal)) {
      _repository.setActiveTerminal(terminal);
      _state = _state.copyWith(
        activeTerminal: terminal,
        isConnected: true,
      );
      _addLog('WiFi: attivo TERM-$terminal.');
    } else {
      _addLog('WiFi: TERM-$terminal non connesso.');
      _state = _state.copyWith(activeTerminal: terminal);
    }
    notifyListeners();
  }

  Future<void> sendAscii(String value) async {
    if (!_state.isConnected) return;

    try {
      await _repository.sendAscii(value);
      _addLog('TX: ${value.replaceAll('\n', '\\n').replaceAll('\r', '\\r')}');
    } catch (e) {
      _addLog('Errore TX: $e');
    }
  }

  void onBytes(Uint8List data) {
    final chunk = String.fromCharCodes(data);

    if (_impostaCompleter != null && !(_impostaCompleter!.isCompleted)) {
      final match = RegExp(r'[A-Za-z]').firstMatch(chunk);
      if (match != null) {
        _impostaCompleter!.complete(match.group(0) == 'A');
      }
    }

    _rxBuffer.write(chunk);

    if (_waitingProbe && chunk.isNotEmpty) {
      _waitingProbe = false;
      _stopConMode(keepButtonState: true);
    }

    while (true) {
      final text = _rxBuffer.toString();
      final i = text.indexOf('*');
      if (i < 0) break;

      final frame = text.substring(0, i);
      _addLog('RX: $frame*');

      if (_pendingImpostaEcho != null) {
        _pendingImpostaEcho = null;
        _rxBuffer.clear();
        _rxBuffer.write(text.substring(i + 1));
        continue;
      }

      if (frame.startsWith('A') || frame.startsWith('X')) {
        final startResult = _frameParser.parseStartResult(
          frame,
          currentUnita: _state.unita,
        );

        final params = _state.params.copyWith(
          capsules: startResult.channels,
        );

        _state = _state.copyWith(
          startResult: startResult,
          unita: startResult.unita,
          params: params,
          isAwaitingStart: false,
        );

        _handleAutoRestartAfterStart();
      } else {
        final params = _frameParser.parseMachineParams(
          frame,
          current: _state.params,
        );

        _state = _state.copyWith(params: params);
      }

      _rxBuffer.clear();
      _rxBuffer.write(text.substring(i + 1));
      notifyListeners();
    }
  }

  Future<void> toggleConMode() async {
    if (!_state.isConnected) return;

    if (_state.isConMode) {
      await onDisMPressed();
    } else {
      _startConMode();
    }
  }

  Future<void> onDisMPressed() async {
    try {
      if (_state.isConnected) {
        for (int i = 0; i < 2; i++) {
          await sendAscii(_commandBuilder.disconnectMachine());
          await Future.delayed(const Duration(milliseconds: 60));
        }
      }
    } catch (_) {}

    _stopConMode();
  }

  void _startConMode() {
    _pollTimer?.cancel();
    _waitingProbe = true;

    _state = _state.copyWith(isConMode: true);
    notifyListeners();

    _pollTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (!_state.isConnected) {
        _stopConMode();
        return;
      }

      if (_waitingProbe) {
        sendAscii('>');
      }
    });
  }

  void _stopConMode({bool keepButtonState = false}) {
    _autoRestartTimer?.cancel();
    _pollTimer?.cancel();
    _pollTimer = null;
    _waitingProbe = false;
    _stopDelaySignal();

    _state = _state.copyWith(
      isAutoLoop: false,
      isConMode: keepButtonState ? _state.isConMode : false,
    );

    notifyListeners();
  }

  Future<void> onStart() async {
    if (!_state.isConnected) return;

    if (_state.timer == 0) {
      await sendAscii(_commandBuilder.start());
      _flashStart();
      return;
    }

    if (_state.isAutoLoop) {
      _autoRestartTimer?.cancel();
      _stopDelaySignal();
      _state = _state.copyWith(isAutoLoop: false);
      notifyListeners();
      return;
    } else {
      _state = _state.copyWith(isAutoLoop: true);
      notifyListeners();
      await sendAscii(_commandBuilder.start());
      _flashStart();
    }
  }

  void _flashStart() {
    _startTimer?.cancel();
    _startTimer = Timer(const Duration(seconds: 1), () {
      notifyListeners();
    });
  }

  Future<void> onImpostaPressed() async {
    final pezzi = _state.params.pezzi;
    if (pezzi < 1 || pezzi > 999) {
      _state = _state.copyWith(hasError: true);
      notifyListeners();
      return;
    }

    _state = _state.copyWith(isAwaitingStart: false);
    notifyListeners();

    try {
      await sendAscii(_commandBuilder.configHandshake());
      final ok = await _waitImpostaAck(const Duration(milliseconds: 1500));
      if (ok) {
        await sendAscii(_commandBuilder.pezzi(pezzi));
      }
    } catch (_) {}
  }

  bool validateRanges() {
    final p = _state.params;

    if (p.pezzi < 1 || p.pezzi > 999) return false;
    if (![1, 2, 3].contains(p.formValue)) return false;
    if (p.seOff < 1 || p.seOff > 255) return false;
    if (p.seOn < 1 || p.seOn > 255) return false;
    if (p.vibCam < 1 || p.vibCam > 100) return false;
    if (p.vibTaz < 1 || p.vibTaz > 100) return false;
    if (p.ritCh < 1 || p.ritCh > 255) return false;

    return true;
  }

  Future<void> sendConfigSet1() async {
    if (!validateRanges()) {
      _state = _state.copyWith(hasError: true);
      notifyListeners();
      return;
    }

    if (_state.isParamBusy) return;

    _state = _state.copyWith(
      isParamBusy: true,
      hasError: false,
      isAwaitingStart: false,
    );
    notifyListeners();

    final p = _state.params;
    bool okAll = true;

    // TRASMETTE I PARAMETRI IN SEQ.
    okAll = okAll && await _sendConfigCommand(_commandBuilder.pezzi(p.pezzi));
    okAll = okAll && await _sendConfigCommand(_commandBuilder.form(p.formValue));
    okAll = okAll && await _sendConfigCommand(_commandBuilder.seOn(p.seOn));
    okAll = okAll && await _sendConfigCommand(_commandBuilder.seOff(p.seOff));
    okAll = okAll && await _sendConfigCommand(_commandBuilder.vibCam(p.vibCam));
    okAll = okAll && await _sendConfigCommand(_commandBuilder.vibTaz(p.vibTaz));

    // nel vecchio flusso dopo la sequenza veniva richiesto l'aggiornamento
    await sendAscii(_commandBuilder.refreshParams());

    _state = _state.copyWith(
      isParamBusy: false,
      hasError: !okAll,
    );
    notifyListeners();
  }

  Future<void> sendConfigSetRit() async {
    if (!validateRanges()) {
      _state = _state.copyWith(hasError: true);
      notifyListeners();
      return;
    }

    if (_state.isParamBusy) return;

    _state = _state.copyWith(
      isParamBusy: true,
      hasError: false,
      isAwaitingStart: false,
    );
    notifyListeners();

    final ok = await _sendConfigCommand(
      _commandBuilder.ritCh(_state.params.ritCh),
    );

    _state = _state.copyWith(
      isParamBusy: false,
      hasError: !ok,
    );
    notifyListeners();
  }

  Future<bool> _sendConfigCommand(String payload) async {
    try {
      await sendAscii(_commandBuilder.configHandshake());

      final ok1 = await _waitImpostaAck(const Duration(milliseconds: 1500));
      if (!ok1) return false;

      _pendingImpostaEcho = 'A$payload*';
      await sendAscii(payload);

      final ok2 = await _waitImpostaAck(const Duration(milliseconds: 1500));

      await Future.delayed(const Duration(milliseconds: 500));

      return ok2;
    } catch (e) {
      _addLog('CONFIG errore: $e');
      return false;
    }
  }

  Future<bool> _waitImpostaAck(Duration timeout) async {
    _impostaCompleter?.complete(false);
    _impostaCompleter = Completer<bool>();

    final timer = Timer(timeout, () {
      if (!(_impostaCompleter!.isCompleted)) {
        _impostaCompleter!.complete(false);
      }
    });

    final ok = await _impostaCompleter!.future;
    timer.cancel();
    _impostaCompleter = null;
    return ok;
  }

  void _handleAutoRestartAfterStart() {
    if (!_state.isAutoLoop || _state.timer <= 0) return;

    _autoRestartTimer?.cancel();
    _startDelaySignal();

    _autoRestartTimer = Timer(Duration(seconds: _state.timer), () async {
      if (!_state.isAutoLoop) return;
      if (!_state.isConnected) return;

      _stopDelaySignal();
      await sendAscii(_commandBuilder.start());
      _flashStart();
    });
  }

  Future<void> playAutoTickBeep() async {
    try {
      FlutterRingtonePlayer().stop();
      FlutterRingtonePlayer().play(
        android: AndroidSounds.notification,
        ios: IosSounds.glass,
        looping: false,
        volume: 1.0,
        asAlarm: true,
      );
      return;
    } catch (_) {
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }

  void _startDelaySignal() {
    if (_delaySignalTimer != null) return;

    _state = _state.copyWith(
      isInAutoDelay: true,
      delayBlinkOn: true,
    );
    notifyListeners();

    _delaySignalTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      await playAutoTickBeep();
      _state = _state.copyWith(delayBlinkOn: !_state.delayBlinkOn);
      notifyListeners();
    });
  }

  void _stopDelaySignal() {
    _delaySignalTimer?.cancel();
    _delaySignalTimer = null;

    _state = _state.copyWith(
      isInAutoDelay: false,
      delayBlinkOn: true,
    );
    notifyListeners();
  }

  Future<void> performExit() async {
    if (_exitInProgress) return;
    _exitInProgress = true;

    try {
      await onDisMPressed();
      await disconnect();
    } catch (_) {}

    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  String _deriveBaseFromHost(String host) {
    final trimmed = host.trim();

    final m4 = RegExp(r'^(\d+)\.(\d+)\.(\d+)\.(\d+)$').firstMatch(trimmed);
    if (m4 != null) {
      return '${m4.group(1)}.${m4.group(2)}.${m4.group(3)}';
    }

    final m3 = RegExp(r'^(\d+)\.(\d+)\.(\d+)$').firstMatch(trimmed);
    if (m3 != null) {
      return m3.group(0)!;
    }

    return '192.168.1';
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final updated = <String>[
      '$timestamp  $message',
      ..._state.logs,
    ];
    _state = _state.copyWith(logs: updated);
    notifyListeners();
  }
}
