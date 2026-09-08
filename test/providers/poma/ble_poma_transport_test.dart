import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yahp_director/providers/config/config_notifier.dart';
import 'package:yahp_director/providers/poma/poma_exception.dart';
import 'package:yahp_director/providers/poma/transport/ble_poma_transport.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.loadFromString(
    envString: 'MONGODB_CONN_STR=mongodb://localhost:27017/test\n',
  );

  group('BlePomaTransport validation', () {
    test('defines Nordic UART Service default UUIDs', () {
      expect(
        BlePomaTransport.pomaServiceUuid,
        '6e400001-b5a3-f393-e0a9-e50e24dcca9e',
      );
      expect(
        BlePomaTransport.pomaRxCharacteristicUuid,
        '6e400002-b5a3-f393-e0a9-e50e24dcca9e',
      );
      expect(
        BlePomaTransport.pomaTxCharacteristicUuid,
        '6e400003-b5a3-f393-e0a9-e50e24dcca9e',
      );
    });

    test(
      'isValidMacOrId identifies valid and invalid MAC addresses or UUIDs',
      () {
        // Valid MAC addresses
        expect(BlePomaTransport.isValidMacOrId('AA:BB:CC:DD:EE:FF'), isTrue);
        expect(BlePomaTransport.isValidMacOrId('aa:bb:cc:dd:ee:ff'), isTrue);
        expect(BlePomaTransport.isValidMacOrId('00-11-22-33-44-55'), isTrue);

        // Valid UUID
        expect(
          BlePomaTransport.isValidMacOrId(
            '8633845e-104c-6597-ac42-66621995fe44',
          ),
          isTrue,
        );

        // Invalid MAC / UUID
        expect(BlePomaTransport.isValidMacOrId(''), isFalse);
        expect(BlePomaTransport.isValidMacOrId('invalid_mac'), isFalse);
        expect(BlePomaTransport.isValidMacOrId('AA:BB:CC:DD:EE'), isFalse);
        expect(BlePomaTransport.isValidMacOrId('AA:BB:CC:DD:EE:GG'), isFalse);
      },
    );

    test('isValidConnection validates device ID', () {
      final validTransport = BlePomaTransport(deviceId: 'AA:BB:CC:DD:EE:FF');
      expect(validTransport.isValidConnection(), isTrue);

      final invalidTransport = BlePomaTransport(deviceId: 'invalid');
      expect(invalidTransport.isValidConnection(), isFalse);
    });

    test('send throws PomaException when transport is not connected', () async {
      final transport = BlePomaTransport(deviceId: 'AA:BB:CC:DD:EE:FF');
      expect(
        () => transport.send(Uint8List.fromList([1, 2, 3])),
        throwsA(isA<PomaException>()),
      );
    });

    test('isConnected defaults to false and close resets state', () async {
      final transport = BlePomaTransport(deviceId: 'AA:BB:CC:DD:EE:FF');
      expect(transport.isConnected(), isFalse);
      await transport.close();
      expect(transport.isConnected(), isFalse);
    });

    test(
      'dispose cancels subscriptions and closes stream controllers cleanly',
      () async {
        final transport = BlePomaTransport(deviceId: 'AA:BB:CC:DD:EE:FF');
        expect(transport.incoming, isNotNull);
        expect(transport.onDebug, isNotNull);

        transport.dispose();
        expect(transport.isConnected(), isFalse);
      },
    );

    test(
      'multiple instances can be created and disposed independently',
      () async {
        final transport1 = BlePomaTransport(deviceId: 'AA:BB:CC:DD:EE:11');
        final transport2 = BlePomaTransport(deviceId: 'AA:BB:CC:DD:EE:22');

        expect(transport1.isConnected(), isFalse);
        expect(transport2.isConnected(), isFalse);

        transport1.dispose();
        expect(transport2.isConnected(), isFalse);

        transport2.dispose();
      },
    );
  });

  group('ConfigNotifier connectionType settings', () {
    test('supports TCP and BLE connection types and device MAC', () {
      final config = ConfigNotifier();
      expect(config.connectionType, ConnectionType.tcp);
      expect(config.deviceMac, '');

      config.updateSettings(
        connectionType: ConnectionType.ble,
        deviceMac: '11:22:33:44:55:66',
      );

      expect(config.connectionType, ConnectionType.ble);
      expect(config.deviceMac, '11:22:33:44:55:66');
    });
  });
}
