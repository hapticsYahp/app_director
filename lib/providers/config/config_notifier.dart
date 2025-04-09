import 'package:flutter/material.dart';

class ConfigNotifier extends ChangeNotifier {
  String _deviceHost = "1.0.0.1";
  int _devicePort = 666;
  String _deviceAuthUser = "lucas\n"; // FIXME: It should not end with "\n".
  String _deviceAuthPass = "stream\n"; // FIXME: It should not end with "\n".
  int _deviceConnectionTimeout = 10;
  bool _deviceConnectionUseCredentials = true;

  String get deviceHost => _deviceHost;

  int get devicePort => _devicePort;

  String get deviceAuthUser => _deviceAuthUser;

  String get deviceAuthPass => _deviceAuthPass;

  int get deviceConnectionTimeout => _deviceConnectionTimeout;

  bool get deviceConnectionUseCredentials => _deviceConnectionUseCredentials;

  void updateSettings({
    String? deviceHost,
    int? devicePort,
    String? deviceAuthUser,
    String? deviceAuthPass,
    int? deviceConnectionTimeout,
    bool? deviceConnectionUseCredentials,
  }) {
    if (deviceHost != null) {
      _deviceHost = deviceHost;
    }
    if (devicePort != null) {
      _devicePort = devicePort;
    }
    if (deviceAuthUser != null) {
      _deviceAuthUser = deviceAuthUser;
    }
    if (deviceAuthPass != null) {
      _deviceAuthPass = deviceAuthPass;
    }
    if (deviceConnectionTimeout != null) {
      _deviceConnectionTimeout = deviceConnectionTimeout;
    }
    if (deviceConnectionUseCredentials != null) {
      _deviceConnectionUseCredentials = deviceConnectionUseCredentials;
    }
    notifyListeners();
  }
}
