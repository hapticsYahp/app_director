import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

abstract class PomaSocket {
  bool isConnected();

  Future<Socket> connect(String host, int port, {Duration? timeout});

  Stream<Uint8List> get stream;

  Future<void> write(String message);

  Future<void> close();

  void dispose();
}
