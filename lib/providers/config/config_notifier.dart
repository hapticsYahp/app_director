import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ConnectionType { tcp, ble }

class ConfigNotifier extends ChangeNotifier {
  static const String _keyConnectionType = 'config_connection_type';
  static const String _keyDeviceHost = 'config_device_host';
  static const String _keyDevicePort = 'config_device_port';
  static const String _keyDeviceMac = 'config_device_mac';
  static const String _keyDeviceConnectionTimeout =
      'config_device_connection_timeout';
  static const String _keyDbUri = 'config_db_uri';

  static String _getEnvDbUri() {
    try {
      if (dotenv.isInitialized) {
        return dotenv.maybeGet('MONGODB_CONN_STR') ?? '';
      }
    } catch (_) {}
    return '';
  }

  ConnectionType _connectionType = ConnectionType.tcp;
  String _deviceHost = "192.168.20.27";
  int _devicePort = 3333;
  String _deviceMac = "";
  int _deviceConnectionTimeout = 10;
  String _dbUri = _getEnvDbUri();
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  ConnectionType get connectionType => _connectionType;

  String get deviceHost => _deviceHost;

  int get devicePort => _devicePort;

  String get deviceMac => _deviceMac;

  int get deviceConnectionTimeout => _deviceConnectionTimeout;

  String get dbUri => _dbUri;

  ConfigNotifier() {
    _loadFromPreferences();
  }

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _connectionType = ConnectionType.values.byName(
        prefs.getString(_keyConnectionType) ?? _connectionType.name,
      );
      _deviceHost = prefs.getString(_keyDeviceHost) ?? _deviceHost;
      _devicePort = prefs.getInt(_keyDevicePort) ?? _devicePort;
      _deviceMac = prefs.getString(_keyDeviceMac) ?? _deviceMac;
      _deviceConnectionTimeout =
          prefs.getInt(_keyDeviceConnectionTimeout) ?? _deviceConnectionTimeout;
      if (prefs.containsKey(_keyDbUri)) {
        _dbUri = prefs.getString(_keyDbUri) ?? '';
      } else {
        _dbUri = _getEnvDbUri();
      }
      _isLoaded = true;
      notifyListeners();
    } catch (_) {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> updateSettings({
    ConnectionType? connectionType,
    String? deviceHost,
    int? devicePort,
    String? deviceMac,
    int? deviceConnectionTimeout,
    String? dbUri,
  }) async {
    if (connectionType != null) {
      _connectionType = connectionType;
    }
    if (deviceHost != null) {
      _deviceHost = deviceHost;
    }
    if (devicePort != null) {
      _devicePort = devicePort;
    }
    if (deviceMac != null) {
      _deviceMac = deviceMac;
    }
    if (deviceConnectionTimeout != null) {
      _deviceConnectionTimeout = deviceConnectionTimeout;
    }
    if (dbUri != null) {
      _dbUri = dbUri;
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (connectionType != null) {
        await prefs.setString(_keyConnectionType, connectionType.name);
      }
      if (deviceHost != null) {
        await prefs.setString(_keyDeviceHost, deviceHost);
      }
      if (devicePort != null) {
        await prefs.setInt(_keyDevicePort, devicePort);
      }
      if (deviceMac != null) {
        await prefs.setString(_keyDeviceMac, deviceMac);
      }
      if (deviceConnectionTimeout != null) {
        await prefs.setInt(
          _keyDeviceConnectionTimeout,
          deviceConnectionTimeout,
        );
      }
      if (dbUri != null) {
        await prefs.setString(_keyDbUri, dbUri);
      }
    } catch (_) {}
  }
}
