import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigNotifier extends ChangeNotifier {
  String _deviceHost = "192.168.20.27";
  int _devicePort = 3333;
  int _deviceConnectionTimeout = 10;
  String _dbUri = dotenv.get('MONGODB_CONN_STR', fallback: '');

  String get deviceHost => _deviceHost;

  int get devicePort => _devicePort;

  int get deviceConnectionTimeout => _deviceConnectionTimeout;

  String get dbUri => _dbUri;

  void updateSettings({
    String? deviceHost,
    int? devicePort,
    int? deviceConnectionTimeout,
    String? dbUri,
  }) {
    if (deviceHost != null) {
      _deviceHost = deviceHost;
    }
    if (devicePort != null) {
      _devicePort = devicePort;
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
