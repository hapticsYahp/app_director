import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yahp_director/pages/home_page.dart';
import 'package:yahp_director/providers/config/config_notifier.dart';
import 'package:yahp_director/providers/poma/poma_client.dart';
import 'package:yahp_director/providers/poma/transport/ble_poma_transport.dart';
import 'package:yahp_director/providers/poma/transport/tcp_poma_transport.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'config_connection_type': 'tcp',
      'config_device_host': '192.168.1.50',
      'config_device_port': 8080,
      'config_device_mac': 'AA:BB:CC:DD:EE:FF',
    });
  });

  testWidgets(
    'HomePage updates PomaClient transport reactively when ConfigNotifier changes',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      final BuildContext innerContext = tester.element(find.byType(TabBarView));
      final configNotifier = Provider.of<ConfigNotifier>(
        innerContext,
        listen: false,
      );
      final pomaClient = Provider.of<PomaClient>(innerContext, listen: false);

      expect(pomaClient.transport, isA<TcpPomaTransport>());

      // Switch connection type to BLE and notify
      await configNotifier.updateSettings(
        connectionType: ConnectionType.ble,
        deviceMac: '11:22:33:44:55:66',
      );
      await tester.pump();

      // PomaClient instance is preserved and its transport is reconfigured to BLE
      expect(pomaClient.transport, isA<BlePomaTransport>());

      // Switch connection type back to TCP and notify
      await configNotifier.updateSettings(
        connectionType: ConnectionType.tcp,
        deviceHost: '10.0.0.1',
        devicePort: 9000,
      );
      await tester.pump();

      expect(pomaClient.transport, isA<TcpPomaTransport>());
    },
  );
}
