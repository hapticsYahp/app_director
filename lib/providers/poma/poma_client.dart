import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:yahp_director/providers/poma/poma_exception.dart';
import 'package:yahp_director/providers/poma/transport/poma_transport.dart';

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
  Future<void> _sendAndWaitQueue = Future.value();

  final StreamController<String> _debugController =
      StreamController.broadcast();

  Stream<String> get onDebug => _debugController.stream;

  PomaTransport _transport;

  PomaTransport get transport => _transport;
  StreamSubscription<String>? _transportDebugSubscription;

  PomaClient(this._transport) {
    _transportDebugSubscription = _transport.onDebug.listen(
      (msg) => _debug("[transport] $msg"),
    );
    _debug("PoMA Client init.");
  }

  Future<void> reconfigure(PomaTransport transport) async {
    _debug("Reconfiguring transport...");
    if (isConnected()) {
      await _transport.close();
    }
    _transportDebugSubscription?.cancel();
    _transport.dispose();
    _transport = transport;
    _transportDebugSubscription = _transport.onDebug.listen(
      (msg) => _debug("[transport] $msg"),
    );
    _debug("Transport reconfigured.");
  }

  void _debug(String message) {
    _debugController.add(message);
  }

  bool isConnected() {
    return _transport.isConnected();
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
    _transport.dispose();
    _failBufferedResponse(PomaException(error.toString()));
  }

  void _onSocketDone() {
    _debug("Socket stream done.");
    _transport.dispose();
    _failBufferedResponse(PomaException("Socket done."));
  }

  Future<void> connect({bool? cancelOnError}) async {
    if (!isConnected()) {
      _debug("Connecting transport...");
      await _transport.open();
      if (!isConnected()) {
        throw PomaException("A connection could not be established.");
      }
      _transport.incoming.listen(
        _onSocketDataReceived,
        onError: _onSocketError,
        onDone: _onSocketDone,
        cancelOnError: cancelOnError,
      );
      _debug("Transport connected.");
    }
  }

  Future<void> disconnect() async {
    if (isConnected()) {
      _debug("Disconnecting from server...");
      await _transport.close();
      _debug("Server disconnected.");
    }
  }

  Future<void> send(String message) async {
    if (!isConnected()) {
      throw PomaException("Cannot send messages to a disconnected server.");
    }
    message = "$message$_messageTerminationChar";
    _debug("Sending message: '$message'...");
    final Uint8List bytes = Uint8List.fromList(utf8.encode(message));
    await _transport.send(bytes);
  }

  Future<String?> sendAndWait(String message) async {
    final previousCommand = _sendAndWaitQueue;
    final currentCommand = Completer<void>();
    _sendAndWaitQueue = currentCommand.future;

    await previousCommand;

    if (!isConnected()) {
      currentCommand.complete();
      throw PomaException("Cannot send messages to a disconnected server.");
    }

    _debug("Sending message and waiting response...");
    final completer = Completer<String>();
    _bufferedResponseCompleter = completer;
    _responseBuffer.clear();

    try {
      await send(message);
      return await completer.future;
    } catch (e) {
      if (_bufferedResponseCompleter == completer) {
        _bufferedResponseCompleter = null;
      }
      rethrow;
    } finally {
      if (!currentCommand.isCompleted) {
        currentCommand.complete();
      }
    }
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
      String? topicValueResponse = await sendAndWait(
        "$_getTopicValueCommandChar $topic",
      );
      if (topicValueResponse != "Getter Key not found") {
        value = topicValueResponse;
      }
    }
    return value;
  }

  Future<bool> setTopicValue(String topic, String value) async {
    bool success = false;
    if (isConnected()) {
      String? setValueResponse = await sendAndWait(
        "$_setTopicValueCommandChar $topic $value",
      );
      success = (setValueResponse == "done");
    }
    return success;
  }

  Future<void> dispose() async {
    await _transportDebugSubscription?.cancel();
    _transportDebugSubscription = null;
    await _debugController.close();
  }
}
