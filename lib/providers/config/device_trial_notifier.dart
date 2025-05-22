import 'package:flutter/material.dart';
import '../../core/trial/device_trial.dart';

class DeviceTrialNotifier extends ChangeNotifier {
  DeviceTrial? _selectedDevice;

  DeviceTrial? get selectedDevice => _selectedDevice;

  void selectDevice(DeviceTrial device) {
    _selectedDevice = device;
    notifyListeners();
  }

  void clearDevice() {
    _selectedDevice = null;
    notifyListeners();
  }
}
