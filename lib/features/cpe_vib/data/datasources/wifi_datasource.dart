import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class WifiDatasource {
  Socket? _socket;
  StreamSubscription<List<int>>? _socketSubscription;

  bool get isConnected => _socket != null;

  Future<bool> connect({
    required String host,
    required int port,
    required void Function(Uint8List data) onData,
    required void Function() onDone,
    required void Function(Object error) onError,
    Duration timeout = const Duration(milliseconds: 900),
  }) async {
    await disconnectAll();

    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      _socket = socket;
      _socketSubscription = socket.listen(
        (data) => onData(Uint8List.fromList(data)),
        onDone: onDone,
        onError: onError,
      );
      return true;
    } catch (_) {
      _socket = null;
      _socketSubscription = null;
      return false;
    }
  }

  Future<void> sendAscii(String value) async {
    final socket = _socket;
    if (socket == null) {
      throw StateError('Socket non attivo');
    }

    socket.add(ascii.encode(value));
    await socket.flush();
  }

  Future<void> disconnectAll() async {
    try {
      await _socketSubscription?.cancel();
    } catch (_) {}

    try {
      await _socket?.close();
    } catch (_) {}

    _socketSubscription = null;
    _socket = null;
  }
}
