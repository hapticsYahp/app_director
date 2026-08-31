import 'dart:async';
import 'dart:typed_data';

import 'package:string_validator/string_validator.dart';
import 'package:universal_ble/universal_ble.dart';
import 'package:yahp_director/providers/poma/poma_exception.dart';
import 'package:yahp_director/providers/poma/transport/poma_transport.dart';

class BlePomaTransport implements PomaTransport {
  // PoMA BLE fixed service/characteristic.
  static const String pomaServiceUuid = "8633845e-104c-6597-ac42-66621995fe44";
  static const String pomaCharacteristicUuid =
      "b9be18d4-5fb4-c9ab-8841-39b87bbf54ab";

  static int _mtu = 23;
  static const int _desiredMtu = 256;

  static int get _chunkSize => _mtu - 3;

  // Multicast registry for UniversalBle.onConnectionChange to prevent clobbering
  // global callbacks across multiple instances or external BLE listeners.
  static final Set<
    void Function(String deviceId, bool isConnected, String? error)
  >
  _connectionChangeListeners = {};
  static bool _isGlobalConnectionCallbackInitialized = false;

  static void _ensureGlobalConnectionCallback() {
    if (!_isGlobalConnectionCallbackInitialized) {
      UniversalBle.onConnectionChange =
          (String deviceId, bool isConnected, String? error) {
            for (final listener in List.of(_connectionChangeListeners)) {
              try {
                listener(deviceId, isConnected, error);
              } catch (_) {
                // Ignore listener errors to avoid disrupting other subscribers.
              }
            }
          };
      _isGlobalConnectionCallbackInitialized = true;
    }
  }

  static void _registerConnectionListener(
    void Function(String deviceId, bool isConnected, String? error) listener,
  ) {
    _ensureGlobalConnectionCallback();
    _connectionChangeListeners.add(listener);
  }

  static void _unregisterConnectionListener(
    void Function(String deviceId, bool isConnected, String? error) listener,
  ) {
    _connectionChangeListeners.remove(listener);
    if (_connectionChangeListeners.isEmpty &&
        _isGlobalConnectionCallbackInitialized) {
      UniversalBle.onConnectionChange = null;
      _isGlobalConnectionCallbackInitialized = false;
    }
  }

  final String _deviceId;
  final Duration _timeout;
  final String _serviceUuid;
  final String _characteristicUuid;

  StreamController<Uint8List> _incomingController =
      StreamController<Uint8List>.broadcast();
  StreamController<String> _debugController =
      StreamController<String>.broadcast();

  StreamSubscription<Uint8List>? _valueSubscription;

  bool _connected = false;

  BlePomaTransport({
    required String deviceId,
    Duration timeout = const Duration(seconds: 10),
    String serviceUuid = pomaServiceUuid,
    String characteristicUuid = pomaCharacteristicUuid,
  }) : _deviceId = deviceId,
       _timeout = timeout,
       _serviceUuid = serviceUuid,
       _characteristicUuid = characteristicUuid;

  void _debug(String message) {
    if (!_debugController.isClosed) {
      _debugController.add(message);
    }
  }

  void _checkValidMacOrId(String macOrId) {
    if (!isValidMacOrId(macOrId)) {
      throw PomaException("Invalid BLE device ID '$macOrId'.");
    }
  }

  void _onBleConnectionChange(
    String deviceId,
    bool isConnected,
    String? error,
  ) {
    if (deviceId == _deviceId && !isConnected) {
      _debug("BLE device disconnected.");
      _connected = false;
      _valueSubscription?.cancel();
      _valueSubscription = null;
      if (error != null && !_incomingController.isClosed) {
        _incomingController.addError(
          PomaException("BLE connection lost: $error"),
        );
      }
    }
  }

  @override
  bool isValidConnection() {
    return isValidMacOrId(_deviceId);
  }

  static bool isValidMacOrId(String macOrId) {
    final macRegex = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
    return macOrId.isNotEmpty &&
        (macOrId.isUUID() || macRegex.hasMatch(macOrId));
  }

  @override
  bool isConnected() => _connected;

  @override
  Stream<Uint8List> get incoming => _incomingController.stream;

  @override
  Stream<String> get onDebug => _debugController.stream;

  @override
  Future<void> open() async {
    _checkValidMacOrId(_deviceId);
    if (_incomingController.isClosed) {
      _incomingController = StreamController<Uint8List>.broadcast();
    }
    if (_debugController.isClosed) {
      _debugController = StreamController<String>.broadcast();
    }
    _debug("Checking Bluetooth availability...");
    try {
      final availability = await UniversalBle.getBluetoothAvailabilityState();
      if (availability != AvailabilityState.poweredOn) {
        throw PomaException(
          "Bluetooth not available (state: ${availability.name}).",
        );
      }
      await UniversalBle.requestPermissions();

      _debug("Connecting to BLE device '$_deviceId'...");
      await UniversalBle.connect(_deviceId, timeout: _timeout);
      _connected = true;

      _debug("Discovering services...");
      final services = await UniversalBle.discoverServices(
        _deviceId,
        timeout: _timeout,
      );

      // Locate the PoMA characteristic to inspect its supported properties.
      BleCharacteristic? pomaChar;
      for (final s in services) {
        for (final c in s.characteristics) {
          _debug("svc=${s.uuid} char=${c.uuid} props=${c.properties}");
          if (s.uuid.toLowerCase() == _serviceUuid.toLowerCase() &&
              c.uuid.toLowerCase() == _characteristicUuid.toLowerCase()) {
            pomaChar = c;
          }
        }
      }
      if (pomaChar == null) {
        throw PomaException(
          "PoMA characteristic $_characteristicUuid not found on device.",
        );
      }

      try {
        _mtu = await UniversalBle.requestMtu(_deviceId, _desiredMtu);
        _debug("Negotiated MTU: $_mtu (useful payload: $_chunkSize bytes)");
      } catch (e) {
        _debug("requestMtu not supported or failed, using default ($_mtu): $e");
      }

      try {
        await UniversalBle.requestConnectionPriority(
          _deviceId,
          BleConnectionPriority.highPerformance,
        );
        _debug("Connection priority: highPerformance");
      } on UniversalBleException catch (e) {
        if (e.code != UniversalBleErrorCode.notSupported) {
          _debug("requestConnectionPriority failed: $e");
        }
      } catch (_) {
        _debug("Connection priority not supported.");
      }

      _valueSubscription =
          UniversalBle.characteristicValueStream(
            _deviceId,
            _characteristicUuid,
          ).listen(
            (Uint8List data) {
              _debug("RX ${data.length} bytes");
              if (!_incomingController.isClosed) {
                _incomingController.add(data);
              }
            },
            onError: (Object error) {
              _debug("BLE value stream error: $error");
              if (!_incomingController.isClosed) {
                _incomingController.addError(error);
              }
            },
          );

      final props = pomaChar.properties;
      if (props.contains(CharacteristicProperty.notify)) {
        _debug("Subscribing to notifications on $_characteristicUuid...");
        await UniversalBle.subscribeNotifications(
          _deviceId,
          _serviceUuid,
          _characteristicUuid,
        );
      } else if (props.contains(CharacteristicProperty.indicate)) {
        _debug("Subscribing to indications on $_characteristicUuid...");
        await UniversalBle.subscribeIndications(
          _deviceId,
          _serviceUuid,
          _characteristicUuid,
        );
      } else {
        throw PomaException(
          "PoMA characteristic does not support notify or indicate.",
        );
      }

      // Register connection change listener via multicast registry.
      _registerConnectionListener(_onBleConnectionChange);

      _debug("BLE device connected.");
    } on PomaException {
      rethrow;
    } catch (e) {
      _debug("BLE connect error: $e");
      _connected = false;
      _unregisterConnectionListener(_onBleConnectionChange);
      throw PomaException("BLE connection failure: $e");
    }
  }

  @override
  Future<void> send(Uint8List data) async {
    if (!isConnected()) {
      throw PomaException("Cannot send data over a disconnected transport.");
    }
    try {
      // Chunk the payload to fit the MTU payload size.
      for (int offset = 0; offset < data.length; offset += _chunkSize) {
        final end = (offset + _chunkSize < data.length)
            ? offset + _chunkSize
            : data.length;
        final chunk = Uint8List.sublistView(data, offset, end);
        await UniversalBle.write(
          _deviceId,
          _serviceUuid,
          _characteristicUuid,
          chunk,
          withoutResponse: false,
        );
      }
    } catch (e) {
      _debug("BLE write error: $e");
      throw PomaException("BLE write failure: $e");
    }
  }

  @override
  Future<void> close() async {
    if (_connected) {
      _debug("Disconnecting from BLE device...");
      try {
        await UniversalBle.unsubscribe(
          _deviceId,
          _serviceUuid,
          _characteristicUuid,
        );
      } catch (_) {
        // Ignore unsubscribe errors on close.
      }
      try {
        await UniversalBle.disconnect(_deviceId);
      } catch (e) {
        _debug("BLE disconnect error: $e");
      }
    }
    _connected = false;
    _valueSubscription?.cancel();
    _valueSubscription = null;
    _unregisterConnectionListener(_onBleConnectionChange);
  }

  @override
  void dispose() {
    _connected = false;
    _valueSubscription?.cancel();
    _valueSubscription = null;
    _unregisterConnectionListener(_onBleConnectionChange);
    if (!_incomingController.isClosed) {
      _incomingController.close();
    }
    if (!_debugController.isClosed) {
      _debugController.close();
    }
  }
}
