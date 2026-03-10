import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class WifiDatasource {
  final Map<int, Socket> _termSocks = {};
  final Map<int, StreamSubscription<List<int>>> _termSubs = {};

  Socket? _activeSocket;

  bool get isConnected => _activeSocket != null;

  Future<Map<int, bool>> connectTerms({
    required String baseIp,
    required int port,
    required void Function(int terminal, Uint8List data) onData,
    required void Function(int terminal) onDone,
    required void Function(int terminal, Object error) onError,
    Duration timeout = const Duration(milliseconds: 800),
  }) async {
    final results = <int, bool>{1: false, 2: false, 3: false};

    await disconnectAll();

    for (final n in [1, 2, 3]) {
      final ip = '$baseIp.${100 + n}';
      try {
        final socket = await Socket.connect(ip, port, timeout: timeout);
        final sub = socket.listen(
              (data) => onData(n, Uint8List.fromList(data)),
          onDone: () => onDone(n),
          onError: (e) => onError(n, e),
        );

        _termSocks[n] = socket;
        _termSubs[n] = sub;
        results[n] = true;
      } catch (_) {
        results[n] = false;
      }
    }

    return results;
  }

  void setActiveTerminal(int terminal) {
    _activeSocket = _termSocks[terminal];
  }

  bool hasTerminal(int terminal) => _termSocks.containsKey(terminal);

  Future<void> sendAscii(String value) async {
    final socket = _activeSocket;
    if (socket == null) {
      throw StateError('Socket non attivo');
    }

    socket.add(ascii.encode(value));
    await socket.flush();
  }

  Future<void> disconnectAll() async {
    for (final sub in _termSubs.values) {
      try {
        await sub.cancel();
      } catch (_) {}
    }

    for (final socket in _termSocks.values) {
      try {
        await socket.close();
      } catch (_) {}
    }

    _termSubs.clear();
    _termSocks.clear();
    _activeSocket = null;
  }
}