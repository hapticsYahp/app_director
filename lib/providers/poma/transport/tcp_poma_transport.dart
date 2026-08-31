import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:string_validator/string_validator.dart';
import 'package:yahp_director/providers/poma/poma_exception.dart';
import 'package:yahp_director/providers/poma/transport/poma_transport.dart';

class TcpPomaTransport implements PomaTransport {
  final String _host;
  final int _port;
  final Duration _timeout;

  Socket? _socket;

  final StreamController<Uint8List> _incomingController =
      StreamController<Uint8List>.broadcast();
  final StreamController<String> _debugController =
      StreamController<String>.broadcast();

  StreamSubscription<Uint8List>? _socketSubscription;

  TcpPomaTransport({
    required String host,
    required int port,
    Duration timeout = const Duration(seconds: 3),
  }) : _host = host,
       _port = port,
       _timeout = timeout;

  void _debug(String message) {
    _debugController.add(message);
  }

  void _checkValidHost(String host) {
    if (!isValidHost(host)) {
      throw PomaException(
        "Invalid PoMA host. '$host' is not a valid domain or IP address.",
      );
    }
  }

  void _checkPort(int port) {
    if (!isValidPort(port)) {
      throw PomaException("PoMA port '$port' is out of range (1-65535).");
    }
  }

  @override
  bool isValidConnection() {
    return isValidHost(_host) && isValidPort(_port);
  }

  static bool isValidHost(String host) {
    if (host.isEmpty) {
      return false;
    }
    final List<RegExp> invalidIpPatterns = [
      RegExp(r'^0\.0\.0\.0$'), // Catch-all.
      RegExp(r'^255\.255\.255\.255$'), // Broadcast.
      RegExp(r'^127\.\d{1,3}\.\d{1,3}\.\d{1,3}$'), // Loopback (127.x.x.x).
      RegExp(r'^169\.254\.\d{1,3}\.\d{1,3}$'), // DHCP local link (169.254.x.x).
      RegExp(r'^224\.\d{1,3}\.\d{1,3}\.\d{1,3}$'), // Multicast (224.x.x.x).
    ];
    if (host.isIP(4)) {
      bool hasTrailingZeroes = host
          .split(".")
          .where((octet) => (octet.length > 1) && octet.startsWith("0"))
          .isNotEmpty;
      return !hasTrailingZeroes &&
          !invalidIpPatterns.any((pattern) => pattern.hasMatch(host));
    }
    if (host.isFQDN()) {
      bool hasLongLabels = host
          .split(".")
          .where((octet) => (octet.length > 63))
          .isNotEmpty;
      return !hasLongLabels;
    }
    return false;
  }

  static bool isValidPort(int port) {
    // FIXME: It should invalidate well-known ports (1-1023).
    return (port >= 1) && (port <= 65_535);
  }

  @override
  bool isConnected() {
    return (_socket != null);
  }

  @override
  Future<void> open() async {
    _checkValidHost(_host);
    _checkPort(_port);
    _debug(
      "Connecting to server '$_host:$_port', with a TimeOut of ${_timeout.inSeconds}s...",
    );
    try {
      _socket = await Socket.connect(_host, _port, timeout: _timeout);
      _socketSubscription = _socket!.listen(
        (Uint8List data) => _incomingController.add(data),
        onError: (Object error) {
          _debug("Socket error: $error");
          _incomingController.addError(error);
        },
        onDone: () {
          _debug("Socket closed by remote.");
          dispose();
          _incomingController.close();
        },
      );
      _debug("Server connected.");
    } on SocketException catch (e) {
      _debug("Socket connect error: ${e.message}.");
      throw PomaException("Connection failure: ${e.message}.");
    }
  }

  @override
  Stream<Uint8List> get incoming => _incomingController.stream;

  @override
  Stream<String> get onDebug => _debugController.stream;

  @override
  Future<void> send(Uint8List data) async {
    if (!isConnected()) {
      throw PomaException("Cannot send data over a disconnected transport.");
    }
    _socket!.add(data);
    await _socket!.flush();
  }

  @override
  Future<void> close() async {
    if (isConnected()) {
      _debug("Disconnecting from server...");
      await _socket!.close();
    }
    dispose();
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    _socketSubscription = null;
    _socket = null;
  }
}
