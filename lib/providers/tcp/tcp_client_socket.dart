import 'dart:io';
import 'package:wifi_app/providers/tcp/tcp_client.dart';

class TcpClientSocket extends TcpClient {
  Socket? _socket;

  @override
  Future<void> connect(
      String host, int port, void Function(String message) onReceive,
      {Function? onError,
      void Function()? onDone,
      bool? cancelOnError,
      Duration? timeout}) async {
    timeout ??= Duration(seconds: 10);
    try {
      _socket = await Socket.connect(host, port, timeout: timeout);
    } catch (e) {
      _socket = null;
    }
    if (isConnected()) {
      _socket!.listen(
        (data) {
          final message = String.fromCharCodes(data);
          onReceive(message);
        },
        onError: (error) {
          _socket = null;
          if (onError != null) {
            onError(error);
          }
        },
        onDone: () {
          _socket = null;
          if (onDone != null) {
            onDone();
          }
        },
        cancelOnError: cancelOnError,
      );
    }
  }

  @override
  Future<void> disconnect() async {
    if (isConnected()) {
      await _socket!.close();
      _socket = null;
    }
  }

  @override
  bool isConnected() {
    return _socket != null;
  }

  @override
  Future<void> send(String message) async {
    if (isConnected()) {
      _socket!.write(message);
    }
  }
}
