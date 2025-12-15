import 'dart:io';
import 'dart:typed_data';
import 'package:yahp_director/providers/poma/poma_socket.dart';

class PomaSocketImpl implements PomaSocket {
  Socket? _socket;

  @override
  bool isConnected() {
    return (_socket != null);
  }

  @override
  Future<Socket> connect(String host, int port, {Duration? timeout}) async {
    _socket = await Socket.connect(host, port, timeout: timeout);
    return _socket!;
  }

  @override
  Stream<Uint8List> get stream => _socket!.asBroadcastStream();

  @override
  Future<void> write(String message) async {
    _socket!.write(message);
    await _socket!.flush();
  }

  @override
  Future<void> close() async {
    await _socket!.close();
    dispose();
  }

  @override
  void dispose() {
    _socket = null;
  }
}
