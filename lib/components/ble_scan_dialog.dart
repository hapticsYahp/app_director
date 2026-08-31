import 'dart:async';

import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';

/// Shows a modal dialog that scans for nearby BLE devices and lets the user
/// pick one. Returns the selected [BleDevice] (or `null` if cancelled).
Future<BleDevice?> showBleScanDialog(BuildContext context) {
  return showDialog<BleDevice>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _BleScanDialog(),
  );
}

class _BleScanDialog extends StatefulWidget {
  const _BleScanDialog();

  @override
  State<_BleScanDialog> createState() => _BleScanDialogState();
}

class _BleScanDialogState extends State<_BleScanDialog> {
  final Map<String, BleDevice> _devices = {};
  StreamSubscription<BleDevice>? _scanSubscription;
  bool _scanning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _stopScan();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _error = null;
      _devices.clear();
      _scanning = true;
    });
    try {
      final state = await UniversalBle.getBluetoothAvailabilityState();
      if (state != AvailabilityState.poweredOn) {
        setState(() {
          _error = "Bluetooth not available (state: ${state.name}).";
          _scanning = false;
        });
        return;
      }
      await UniversalBle.requestPermissions();
      _scanSubscription = UniversalBle.scanStream.listen(
        (device) {
          setState(() {
            _devices[device.deviceId] = device;
          });
        },
        onError: (Object err) {
          setState(() {
            _error = "Scan error: $err";
            _scanning = false;
          });
        },
      );
      await UniversalBle.startScan();
    } catch (e) {
      setState(() {
        _error = "Failed to start scan: $e";
        _scanning = false;
      });
    }
  }

  Future<void> _stopScan() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    try {
      await UniversalBle.stopScan();
    } catch (_) {
      // Ignore errors on stop.
    }
    if (mounted) {
      setState(() {
        _scanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final devices = _devices.values.toList()
      ..sort((a, b) => (b.rssi ?? -1000).compareTo(a.rssi ?? -1000));
    return AlertDialog(
      title: Row(
        children: [
          const Expanded(child: Text("BLE devices")),
          if (_scanning)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 360,
        child: _error != null
            ? Center(
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            : devices.isEmpty
                ? Center(
                    child: Text(_scanning
                        ? "Searching for devices..."
                        : "No devices found."),
                  )
                : ListView.separated(
                    itemCount: devices.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final d = devices[index];
                      final name =
                          (d.name?.isNotEmpty ?? false) ? d.name! : "(unknown)";
                      return ListTile(
                        dense: true,
                        title: Text(name),
                        subtitle: Text(d.deviceId),
                        trailing: d.rssi != null ? Text("${d.rssi} dBm") : null,
                        onTap: () async {
                          await _stopScan();
                          if (context.mounted) {
                            Navigator.of(context).pop(d);
                          }
                        },
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
          onPressed: _scanning ? _stopScan : _startScan,
          child: Text(_scanning ? "Stop" : "Rescan"),
        ),
        TextButton(
          onPressed: () async {
            await _stopScan();
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
