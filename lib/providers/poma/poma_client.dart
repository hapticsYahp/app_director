import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:string_validator/string_validator.dart';
import 'package:wifi_app/providers/poma/poma_exception.dart';
import 'package:wifi_app/providers/poma/poma_socket.dart';

class PomaClient {
  static final String _listTopicsCommandChar = "*";
  static final String _topicsSeparator = " | ";
  static final String _getTopicValueCommandChar = "?";
  static final String _setTopicValueCommandChar = "=";
  static final String _messagePrefix = "ACK: ";
  static final String _messageTerminationChar = "\x00";
  static final String _messageResponseDelimiter = "\n";

  final StringBuffer _responseBuffer = StringBuffer();
  Completer<String>? _bufferedResponseCompleter;

  final StreamController<String> _debugController =
      StreamController.broadcast();

  Stream<String> get onDebug => _debugController.stream;

  final PomaSocket _socket;

  PomaClient(this._socket) {
    _debug("PoMA Client init.");
  }

  void _debug(String message) {
    _debugController.add(message);
  }

  bool isConnected() {
    return _socket.isConnected();
  }

  void _completeBufferedResponse(String response) {
    if (_bufferedResponseCompleter != null) {
      _debug("Returning buffered response: '$response'.");
      _bufferedResponseCompleter!.complete(response);
      _bufferedResponseCompleter = null;
    }
  }

  void _failBufferedResponse(Object error) {
    if (_bufferedResponseCompleter != null) {
      _debug("Completing buffered response with error: '$error'.");
      _bufferedResponseCompleter!.completeError(error);
      _bufferedResponseCompleter = null;
    }
  }

  void _onSocketDataReceived(Uint8List data) {
    String message = String.fromCharCodes(data);
    _debug("Message received: '$message'.");
    message = message.replaceAll(_messageTerminationChar, "");
    _responseBuffer.write(message);
    if (message.contains(_messageResponseDelimiter)) {
      String response = _responseBuffer
          .toString()
          .split(_messageResponseDelimiter)
          .first
          .replaceFirst(_messagePrefix, "");
      _responseBuffer.clear();
      _completeBufferedResponse(response);
    }
  }

  void _onSocketError(Object error) {
    _debug("Socket error: $error");
    _socket.dispose();
    _failBufferedResponse(PomaException(error.toString()));
  }

  void _onSocketDone() {
    _debug("Socket stream done.");
    _socket.dispose();
    _failBufferedResponse(PomaException("Socket done."));
  }

  bool isValidHost(String host) {
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
      bool hasLongLabels =
          host.split(".").where((octet) => (octet.length > 63)).isNotEmpty;
      return !hasLongLabels;
    }
    return false;
  }

  void _checkValidHost(String host) {
    if (!isValidHost(host)) {
      throw PomaException(
          "Invalid PoMA host. '$host' is not a valid domain or IP address.");
    }
  }

  bool isValidPort(int port) {
    // FIXME: It should invalidate well-known ports (1-1023).
    return (port >= 1) && (port <= 65_535);
  }

  void _checkPort(int port) {
    if (!isValidPort(port)) {
      throw PomaException("PoMA port '$port' is out of range (1-65535).");
    }
  }

  Future<void> connect(
    String serverHost,
    int serverPort, {
    Duration timeout = const Duration(seconds: 3),
    bool? cancelOnError,
  }) async {
    if (!isConnected()) {
      _checkValidHost(serverHost);
      _checkPort(serverPort);
      _debug(
          "Connecting to server '$serverHost:$serverPort', with a TimeOut of ${timeout.inSeconds}s, cancel on error: $cancelOnError...");
      try {
        await _socket.connect(serverHost, serverPort, timeout: timeout);
        _socket.stream.listen(
          _onSocketDataReceived,
          onError: _onSocketError,
          onDone: _onSocketDone,
          cancelOnError: cancelOnError,
        );
        _debug("Server connected.");
      } on SocketException catch (e) {
        _debug("Socket connect error: ${e.message}.");
        throw PomaException("Connection failure: ${e.message}.");
      }
    }
  }

  Future<void> disconnect() async {
    if (isConnected()) {
      _debug("Disconnecting from server...");
      await _socket.close();
      _debug("Server disconnected.");
    }
  }

  Future<void> send(String message) async {
    if (!isConnected()) {
      throw PomaException("Cannot send messages to a disconnected server.");
    }
    _debug("Sending message: '$message'...");
    await _socket.write("$message$_messageTerminationChar");
  }

  Future<String?> sendAndWait(String message) async {
    if (!isConnected()) {
      throw PomaException("Cannot send messages to a disconnected server.");
    }
    _debug("Sending message and waiting response...");
    _bufferedResponseCompleter = Completer<String>();
    _responseBuffer.clear();
    await send(message);
    return _bufferedResponseCompleter!.future;
  }

  Future<List<String>> getTopics() async {
    List<String> topics = [];
    if (isConnected()) {
      _debug("Parsing topics...");
      String? topicsResponse = await sendAndWait(_listTopicsCommandChar);
      if (topicsResponse != null) {
        _debug("Parsing topics...");
        topics = topicsResponse
            .split(_topicsSeparator)
            .map((topic) => topic.trim())
            .where((topic) => topic.isNotEmpty)
            .toList();
        _debug("Topics: ${topics.join(',')}.");
      }
    }
    return topics;
  }

  Future<String?> getTopicValue(String topic) async {
    String? value;
    if (isConnected()) {
      String? topicValueResponse =
          await sendAndWait("$_getTopicValueCommandChar $topic");
      if (topicValueResponse != "Getter Key not found") {
        value = topicValueResponse;
      }
    }
    return value;
  }

  Future<bool> setTopicValue(String topic, String value) async {
    bool success = false;
    if (isConnected()) {
      String? setValueResponse =
          await sendAndWait("$_setTopicValueCommandChar $topic $value");
      success = (setValueResponse == "done");
    }
    return success;
  }
}
