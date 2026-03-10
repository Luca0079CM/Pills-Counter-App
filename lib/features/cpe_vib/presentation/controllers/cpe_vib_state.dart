import '../../domain/entities/app_settings.dart';
import '../../domain/entities/machine_params.dart';
import '../../domain/entities/start_result.dart';

class CpeVibState {
  final bool isConnected;
  final bool isConMode;
  final bool isParamBusy;
  final bool isAwaitingStart;
  final bool isAutoLoop;
  final bool isInAutoDelay;
  final bool delayBlinkOn;
  final bool hasError;

  final int pageIndex;
  final int timer;
  final int? activeTerminal;
  final int unita;

  final AppSettings settings;
  final MachineParams params;
  final StartResult startResult;

  final List<String> logs;
  final String host;
  final String port;
  final String outgoingText;

  const CpeVibState({
    required this.isConnected,
    required this.isConMode,
    required this.isParamBusy,
    required this.isAwaitingStart,
    required this.isAutoLoop,
    required this.isInAutoDelay,
    required this.delayBlinkOn,
    required this.hasError,
    required this.pageIndex,
    required this.timer,
    required this.activeTerminal,
    required this.unita,
    required this.settings,
    required this.params,
    required this.startResult,
    required this.logs,
    required this.host,
    required this.port,
    required this.outgoingText,
  });

  factory CpeVibState.initial() {
    return CpeVibState(
      isConnected: false,
      isConMode: false,
      isParamBusy: false,
      isAwaitingStart: false,
      isAutoLoop: false,
      isInAutoDelay: false,
      delayBlinkOn: true,
      hasError: false,
      pageIndex: 0,
      timer: 0,
      activeTerminal: null,
      unita: 0,
      settings: AppSettings.initial(),
      params: MachineParams.initial(),
      startResult: StartResult.initial(),
      logs: const [],
      host: '192.168.1.101',
      port: '5000',
      outgoingText: '',
    );
  }

  CpeVibState copyWith({
    bool? isConnected,
    bool? isConMode,
    bool? isParamBusy,
    bool? isAwaitingStart,
    bool? isAutoLoop,
    bool? isInAutoDelay,
    bool? delayBlinkOn,
    bool? hasError,
    int? pageIndex,
    int? timer,
    int? activeTerminal,
    int? unita,
    AppSettings? settings,
    MachineParams? params,
    StartResult? startResult,
    List<String>? logs,
    String? host,
    String? port,
    String? outgoingText,
  }) {
    return CpeVibState(
      isConnected: isConnected ?? this.isConnected,
      isConMode: isConMode ?? this.isConMode,
      isParamBusy: isParamBusy ?? this.isParamBusy,
      isAwaitingStart: isAwaitingStart ?? this.isAwaitingStart,
      isAutoLoop: isAutoLoop ?? this.isAutoLoop,
      isInAutoDelay: isInAutoDelay ?? this.isInAutoDelay,
      delayBlinkOn: delayBlinkOn ?? this.delayBlinkOn,
      hasError: hasError ?? this.hasError,
      pageIndex: pageIndex ?? this.pageIndex,
      timer: timer ?? this.timer,
      activeTerminal: activeTerminal ?? this.activeTerminal,
      unita: unita ?? this.unita,
      settings: settings ?? this.settings,
      params: params ?? this.params,
      startResult: startResult ?? this.startResult,
      logs: logs ?? this.logs,
      host: host ?? this.host,
      port: port ?? this.port,
      outgoingText: outgoingText ?? this.outgoingText,
    );
  }
}