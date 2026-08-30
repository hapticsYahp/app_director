import 'dart:async';
import 'dart:typed_data';

abstract class PomaTransport {
  bool isValidConnection();

  bool isConnected();

  Future<void> open();

  Future<void> close();

  Stream<Uint8List> get incoming;

  Stream<String> get onDebug;

  Future<void> send(Uint8List data);

  void dispose();
}
