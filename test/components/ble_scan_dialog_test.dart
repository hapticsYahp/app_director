import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_ble/universal_ble.dart';
import 'package:yahp_director/components/ble_scan_dialog.dart';

class MockUniversalBlePlatform extends UniversalBlePlatform {
  AvailabilityState availabilityState = AvailabilityState.poweredOn;
  int startScanCalls = 0;
  int stopScanCalls = 0;

  @override
  Future<AvailabilityState> getBluetoothAvailabilityState() async {
    return availabilityState;
  }

  @override
  Future<bool> enableBluetooth() async => true;

  @override
  Future<bool> disableBluetooth() async => true;

  @override
  Future<void> requestPermissions({
    bool withAndroidFineLocation = false,
  }) async {}

  @override
  Future<void> startScan({
    ScanFilter? scanFilter,
    PlatformConfig? platformConfig,
  }) async {
    startScanCalls++;
  }

  @override
  Future<void> stopScan() async {
    stopScanCalls++;
  }

  @override
  Future<bool> isScanning() async => false;

  @override
  Future<void> connect(
    String deviceId, {
    Duration? connectionTimeout,
    bool autoConnect = false,
    ConnectionPlatformConfig? platformConfig,
  }) async {}

  @override
  Future<void> disconnect(String deviceId) async {}

  @override
  Future<List<BleService>> discoverServices(
    String deviceId,
    bool withDescriptors,
  ) async => [];

  @override
  Future<void> setNotifiable(
    String deviceId,
    String service,
    String characteristic,
    BleInputProperty bleInputProperty,
  ) async {}

  @override
  Future<Uint8List> readValue(
    String deviceId,
    String service,
    String characteristic, {
    Duration? timeout,
  }) async => Uint8List(0);

  @override
  Future<Uint8List> readDescriptorValue(
    String deviceId,
    String service,
    String characteristic,
    String descriptor, {
    Duration? timeout,
  }) async => Uint8List(0);

  @override
  Future<void> writeValue(
    String deviceId,
    String service,
    String characteristic,
    Uint8List value,
    BleOutputProperty bleOutputProperty,
  ) async {}

  @override
  Future<void> writeDescriptorValue(
    String deviceId,
    String service,
    String characteristic,
    String descriptor,
    Uint8List value,
  ) async {}

  @override
  Future<int> requestMtu(String deviceId, int expectedMtu) async => 23;

  @override
  Future<int> readRssi(String deviceId) async => -50;

  @override
  Future<void> requestConnectionPriority(
    String deviceId,
    BleConnectionPriority priority,
  ) async {}

  @override
  Future<bool> isPaired(String deviceId) async => false;

  @override
  Future<bool> pair(String deviceId) async => true;

  @override
  Future<void> unpair(String deviceId) async {}

  @override
  Future<BleConnectionState> getConnectionState(String deviceId) async =>
      BleConnectionState.disconnected;

  @override
  Future<List<BleDevice>> getSystemDevices(List<String>? withServices) async =>
      [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockUniversalBlePlatform mockPlatform;

  setUp(() {
    UniversalBle.queueType = QueueType.none;
    UniversalBle.timeout = null;
    mockPlatform = MockUniversalBlePlatform();
    UniversalBle.setInstance(mockPlatform);
  });

  testWidgets('showBleScanDialog displays dialog and can be cancelled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showBleScanDialog(context),
              child: const Text('Open Scan'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Scan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('BLE devices'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('BLE devices'), findsNothing);
    expect(mockPlatform.stopScanCalls, greaterThan(0));
  });

  testWidgets(
    'showBleScanDialog shows error when bluetooth is not powered on',
    (WidgetTester tester) async {
      mockPlatform.availabilityState = AvailabilityState.poweredOff;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showBleScanDialog(context),
                child: const Text('Open Scan'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Scan'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Bluetooth not available'), findsOneWidget);
      expect(find.text('Rescan'), findsOneWidget);

      // Turn bluetooth on and tap Rescan
      mockPlatform.availabilityState = AvailabilityState.poweredOn;
      await tester.tap(find.text('Rescan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Searching for devices...'), findsOneWidget);
      expect(mockPlatform.startScanCalls, 1);
    },
  );

  testWidgets('showBleScanDialog displays discovered devices and selects one', (
    WidgetTester tester,
  ) async {
    BleDevice? selectedDevice;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                selectedDevice = await showBleScanDialog(context);
              },
              child: const Text('Open Scan'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Scan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Searching for devices...'), findsOneWidget);

    // Emit a discovered device
    final testDevice = BleDevice(
      deviceId: 'AA:BB:CC:DD:EE:FF',
      name: 'Haptic Device',
      rssi: -50,
    );
    mockPlatform.updateScanResult(testDevice);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Haptic Device'), findsOneWidget);
    expect(find.text('AA:BB:CC:DD:EE:FF'), findsOneWidget);
    expect(find.text('-50 dBm'), findsOneWidget);

    // Tap device to select
    await tester.tap(find.text('Haptic Device'));
    await tester.pumpAndSettle();

    expect(find.text('BLE devices'), findsNothing);
    expect(selectedDevice, isNotNull);
    expect(selectedDevice?.deviceId, 'AA:BB:CC:DD:EE:FF');
    expect(selectedDevice?.name, 'Haptic Device');
  });

  testWidgets(
    'showBleScanDialog stops scanning with Stop button and resumes with Rescan',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showBleScanDialog(context),
                child: const Text('Open Scan'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Scan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Stop'), findsOneWidget);
      expect(find.text('Searching for devices...'), findsOneWidget);

      // Tap Stop
      await tester.tap(find.text('Stop'));
      await tester.pumpAndSettle();

      expect(find.text('Rescan'), findsOneWidget);
      expect(find.text('No devices found.'), findsOneWidget);

      // Tap Rescan
      await tester.tap(find.text('Rescan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Stop'), findsOneWidget);
      expect(find.text('Searching for devices...'), findsOneWidget);

      // Cancel dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('BLE devices'), findsNothing);
    },
  );
}
