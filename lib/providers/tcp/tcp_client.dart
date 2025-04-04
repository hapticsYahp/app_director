abstract class TcpClient {
  Future<void> connect(
      String host, int port, void Function(String message) onReceive,
      {Function? onError,
      void Function()? onDone,
      bool? cancelOnError,
      Duration? timeout});

  Future<void> disconnect();

  bool isConnected();

  Future<void> send(String message);
}
