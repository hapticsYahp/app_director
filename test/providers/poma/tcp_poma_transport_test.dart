import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:yahp_director/providers/poma/poma_exception.dart';
import 'package:yahp_director/providers/poma/transport/tcp_poma_transport.dart';

void main() {
  group('TcpPomaTransport validation', () {
    test('isValidHost identifies valid and invalid hosts', () {
      expect(TcpPomaTransport.isValidHost('192.168.1.100'), isTrue);
      expect(TcpPomaTransport.isValidHost('example.com'), isTrue);
      expect(TcpPomaTransport.isValidHost('sub.domain.local'), isTrue);

      expect(TcpPomaTransport.isValidHost(''), isFalse);
      expect(TcpPomaTransport.isValidHost('0.0.0.0'), isFalse);
      expect(TcpPomaTransport.isValidHost('255.255.255.255'), isFalse);
      expect(TcpPomaTransport.isValidHost('127.0.0.1'), isFalse);
      expect(TcpPomaTransport.isValidHost('169.254.1.1'), isFalse);
      expect(TcpPomaTransport.isValidHost('224.0.0.1'), isFalse);
      expect(TcpPomaTransport.isValidHost('192.168.01.1'), isFalse);
    });

    test('isValidPort identifies valid and invalid ports', () {
      expect(TcpPomaTransport.isValidPort(1), isTrue);
      expect(TcpPomaTransport.isValidPort(8080), isTrue);
      expect(TcpPomaTransport.isValidPort(65535), isTrue);

      expect(TcpPomaTransport.isValidPort(0), isFalse);
      expect(TcpPomaTransport.isValidPort(-1), isFalse);
      expect(TcpPomaTransport.isValidPort(65536), isFalse);
    });

    test('isValidConnection validates host and port', () {
      final validTransport = TcpPomaTransport(host: '192.168.1.50', port: 3333);
      expect(validTransport.isValidConnection(), isTrue);

      final invalidTransport = TcpPomaTransport(host: '0.0.0.0', port: 3333);
      expect(invalidTransport.isValidConnection(), isFalse);
    });

    test('open throws PomaException when host is invalid', () async {
      final transport = TcpPomaTransport(host: '127.0.0.1', port: 3333);
      expect(() => transport.open(), throwsA(isA<PomaException>()));
    });

    test('open throws PomaException when port is invalid', () async {
      final transport = TcpPomaTransport(host: '192.168.1.50', port: 99999);
      expect(() => transport.open(), throwsA(isA<PomaException>()));
    });

    test('send throws PomaException when transport is not connected', () async {
      final transport = TcpPomaTransport(host: '192.168.1.50', port: 3333);
      expect(
        () => transport.send(Uint8List.fromList([1, 2, 3])),
        throwsA(isA<PomaException>()),
      );
    });
  });
}
