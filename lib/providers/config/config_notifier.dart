import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum ConnectionType { tcp, ble }

class ConfigNotifier extends ChangeNotifier {
  ConnectionType _connectionType = ConnectionType.tcp;
  String _deviceHost = "192.168.20.27";
  int _devicePort = 3333;
  String _deviceMac = "";
  int _deviceConnectionTimeout = 10;
  String _dbUri = dotenv.get('MONGODB_CONN_STR', fallback: '');

  ConnectionType get connectionType => _connectionType;

  String get deviceHost => _deviceHost;

  int get devicePort => _devicePort;

  String get deviceMac => _deviceMac;

  int get deviceConnectionTimeout => _deviceConnectionTimeout;

  String get dbUri => _dbUri;

  void updateSettings({
    ConnectionType? connectionType,
    String? deviceHost,
    int? devicePort,
    String? deviceMac,
    int? deviceConnectionTimeout,
    String? dbUri,
  }) {
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
  }
}
