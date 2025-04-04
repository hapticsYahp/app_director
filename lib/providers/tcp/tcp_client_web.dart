import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:wifi_app/providers/tcp/tcp_client.dart';

class TcpClientWeb extends TcpClient {
  WebSocketChannel? _channel;

  @override
  Future<void> connect(
      String host, int port, void Function(String message) onReceive,
      {Function? onError,
      void Function()? onDone,
      bool? cancelOnError,
      Duration? timeout}) async {
    try {
      final wsUrl = Uri.parse('ws://$host:$port');
      _channel = WebSocketChannel.connect(wsUrl);
      await _channel!.ready;
    } catch (e) {
      _channel = null;
    }
    if (isConnected()) {
      _channel!.stream.listen(
        (data) {
          final message = String.fromCharCodes(data);
          onReceive(message);
        },
        onError: (error) {
          _channel = null;
          if (onError != null) {
            onError(error);
          }
        },
        onDone: () {
          _channel = null;
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
      await _channel!.sink.close(status.goingAway);
      _channel = null;
    }
  }

  @override
  bool isConnected() {
    return _channel != null;
  }

  @override
  Future<void> send(String message) async {
    if (isConnected()) {
      _channel!.sink.add(message);
    }
  }
}
