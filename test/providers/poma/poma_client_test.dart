import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:yahp_director/providers/poma/poma_client.dart';
import 'package:yahp_director/providers/poma/poma_exception.dart';
import 'package:yahp_director/providers/poma/transport/poma_transport.dart';

class FakePomaTransport implements PomaTransport {
  bool connected = false;
  final StreamController<Uint8List> _incomingController =
      StreamController<Uint8List>.broadcast();
  final StreamController<String> _debugController =
      StreamController<String>.broadcast();

  final List<Uint8List> sentData = [];
  bool openCalled = false;
  bool closeCalled = false;
  bool disposeCalled = false;

  void emitIncoming(String data) {
    _incomingController.add(Uint8List.fromList(utf8.encode(data)));
  }

  void emitError(Object error) {
    _incomingController.addError(error);
  }

  @override
  bool isValidConnection() => true;

  @override
  bool isConnected() => connected;

  @override
  Future<void> open() async {
    openCalled = true;
    connected = true;
  }

  @override
  Future<void> close() async {
    closeCalled = true;
    connected = false;
  }

  @override
  Stream<Uint8List> get incoming => _incomingController.stream;

  @override
  Stream<String> get onDebug => _debugController.stream;

  @override
  Future<void> send(Uint8List data) async {
    sentData.add(data);
  }

  @override
  void dispose() {
    disposeCalled = true;
    connected = false;
  }
}

void main() {
  late FakePomaTransport fakeTransport;
  late PomaClient pomaClient;

  setUp(() {
    fakeTransport = FakePomaTransport();
    pomaClient = PomaClient(fakeTransport);
  });

  tearDown(() async {
    await pomaClient.dispose();
  });

  group('PomaClient lifecycle & connection', () {
    test('isConnected reflects transport status', () {
      expect(pomaClient.isConnected(), isFalse);
      fakeTransport.connected = true;
      expect(pomaClient.isConnected(), isTrue);
    });

    test('connect opens transport and listens to incoming', () async {
      await pomaClient.connect();
      expect(fakeTransport.openCalled, isTrue);
      expect(pomaClient.isConnected(), isTrue);
    });

    test('disconnect closes transport', () async {
      await pomaClient.connect();
      await pomaClient.disconnect();
      expect(fakeTransport.closeCalled, isTrue);
      expect(pomaClient.isConnected(), isFalse);
    });

    test('reconfigure closes existing and replaces transport', () async {
      await pomaClient.connect();
      final newTransport = FakePomaTransport();
      await pomaClient.reconfigure(newTransport);
      expect(fakeTransport.closeCalled, isTrue);
      expect(fakeTransport.disposeCalled, isTrue);
      expect(pomaClient.isConnected(), isFalse);
    });
  });

  group('PomaClient messaging and commands', () {
    test('send throws when not connected', () async {
      expect(() => pomaClient.send('test'), throwsA(isA<PomaException>()));
    });

    test('send appends termination char and encodes utf-8', () async {
      await pomaClient.connect();
      await pomaClient.send('cmd');
      expect(fakeTransport.sentData.length, 1);
      expect(utf8.decode(fakeTransport.sentData.first), 'cmd\x00');
    });

    test('sendAndWait sends command and waits for ACK response', () async {
      await pomaClient.connect();
      final future = pomaClient.sendAndWait('hello');

      fakeTransport.emitIncoming('ACK: response_data\n\x00');

      final result = await future;
      expect(result, 'response_data');
    });

    test('getTopics parses topic list from ACK response with null terminator only', () async {
      await pomaClient.connect();
      final future = pomaClient.getTopics();

      fakeTransport.emitIncoming('ACK: topic1 | intensity | topic3 | \x00');

      final topics = await future;
      expect(topics, ['topic1', 'intensity', 'topic3']);
    });

    test('getTopics parses topic list from ACK response with newline only', () async {
      await pomaClient.connect();
      final future = pomaClient.getTopics();

      fakeTransport.emitIncoming('ACK: topic1 | intensity | topic3\n');

      final topics = await future;
      expect(topics, ['topic1', 'intensity', 'topic3']);
    });

    test('getTopics parses topic list from ACK response with CRLF', () async {
      await pomaClient.connect();
      final future = pomaClient.getTopics();

      fakeTransport.emitIncoming('ACK: topic1 | intensity | topic3\r\n');

      final topics = await future;
      expect(topics, ['topic1', 'intensity', 'topic3']);
    });

    test('getTopics parses chunked response across multiple incoming packets', () async {
      await pomaClient.connect();
      final future = pomaClient.getTopics();

      fakeTransport.emitIncoming('ACK: topic1 | inten');
      fakeTransport.emitIncoming('sity | topic3 | \x00');

      final topics = await future;
      expect(topics, ['topic1', 'intensity', 'topic3']);
    });

    test('sendAndWait throws PomaException on timeout', () async {
      await pomaClient.connect();
      pomaClient.responseTimeout = const Duration(milliseconds: 50);
      expect(
        () => pomaClient.sendAndWait('hello'),
        throwsA(isA<PomaException>()),
      );
    });

    test('getTopics parses topic list from ACK response', () async {
      await pomaClient.connect();
      final future = pomaClient.getTopics();

      fakeTransport.emitIncoming('ACK: topicA | topicB | topicC\n\x00');

      final topics = await future;
      expect(topics, ['topicA', 'topicB', 'topicC']);
    });

    test('getTopicValue returns value when found', () async {
      await pomaClient.connect();
      final future = pomaClient.getTopicValue('intensity');

      fakeTransport.emitIncoming('ACK: 50\n\x00');

      final value = await future;
      expect(value, '50');
    });

    test('getTopicValue returns null when key not found', () async {
      await pomaClient.connect();
      final future = pomaClient.getTopicValue('non_existing');

      fakeTransport.emitIncoming('ACK: Getter Key not found\n\x00');

      final value = await future;
      expect(value, isNull);
    });

    test('setTopicValue returns true when done', () async {
      await pomaClient.connect();
      final future = pomaClient.setTopicValue('intensity', '80');

      fakeTransport.emitIncoming('ACK: done\n\x00');

      final success = await future;
      expect(success, isTrue);
    });

    test('setTopicValue returns false when error returned', () async {
      await pomaClient.connect();
      final future = pomaClient.setTopicValue('intensity', '80');

      fakeTransport.emitIncoming('ACK: fail\n\x00');

      final success = await future;
      expect(success, isFalse);
    });
  });
}
