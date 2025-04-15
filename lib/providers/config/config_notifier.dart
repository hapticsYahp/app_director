import 'package:flutter/material.dart';

class ConfigNotifier extends ChangeNotifier {
  String _deviceHost = "192.168.20.27";
  int _devicePort = 3333;
  int _deviceConnectionTimeout = 10;

  String get deviceHost => _deviceHost;

  int get devicePort => _devicePort;

  int get deviceConnectionTimeout => _deviceConnectionTimeout;

  void updateSettings({
    String? deviceHost,
    int? devicePort,
    String? deviceAuthUser,
    String? deviceAuthPass,
    int? deviceConnectionTimeout,
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
    notifyListeners();
  }
}
