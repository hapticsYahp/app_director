import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yahp_director/core/trial/device_trial.dart';
import '../../../providers/data/data_provider.dart';
import '../../providers/config/device_trial_notifier.dart';

class DeviceForm extends StatefulWidget {
  const DeviceForm({super.key});

  @override
  State<DeviceForm> createState() => _DeviceFormState();
}

class _DeviceFormState extends State<DeviceForm> {
  bool _isSaving = false;

  DeviceTrial? _device;

  bool get _formVisible => (_device != null);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _formKey.currentState?.validate() ?? false;
  }

  bool get _hasFormChanged {
    return _device?.name != _nameController.text;
  }

  bool get _canSave =>
      (!_isSaving && _formVisible && _isFormValid && _hasFormChanged);

  void _createNewDevice() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final deviceNotifier =
        Provider.of<DeviceTrialNotifier>(context, listen: false);
    DeviceTrial device = await dataProvider.createDeviceTrial('Device Name');
    setState(() {
      _device = device;
      _nameController.text = device.name;
    });
    deviceNotifier.selectDevice(device);
  }

  Future<void> _getDevice() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final name = await _promptDeviceName(context);
    if (name == null || name.trim().isEmpty) return;
    final results = await dataProvider.searchDevicesByName(name);
    if (!mounted) return;
    if (results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No devices found.')),
      );
      return;
    }
    final deviceNotifier =
        Provider.of<DeviceTrialNotifier>(context, listen: false);
    final DeviceTrial? selected = (results.length == 1)
        ? results.first
        : await _selectDeviceFromList(context, results);
    if (selected != null) {
      setState(() {
        _device = selected;
        _nameController.text = selected.name;
      });
      deviceNotifier.selectDevice(selected);
    }
  }

  Future<void> _saveDevice() async {
    if (!_canSave) return;

    setState(() => _isSaving = true);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final device = _device!;
    device.name = _nameController.text;

    await dataProvider.saveDevice(device);
    setState(() => _isSaving = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Device saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _formVisible
        ? Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: _device!.id,
                  decoration: const InputDecoration(
                    labelText: 'Device ID',
                  ),
                  readOnly: true,
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Invalid name.';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _canSave ? _saveDevice : null,
                      child: _isSaving
                          ? const CircularProgressIndicator()
                          : const Text('Save'),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {
                        Provider.of<DeviceTrialNotifier>(context, listen: false)
                            .clearDevice();
                        setState(() {
                          _device = null;
                          _nameController.clear();
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _getDevice,
                icon: const Icon(Icons.search),
                label: const Text('Get Existing Device'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _createNewDevice,
                icon: const Icon(Icons.add),
                label: const Text('New Device'),
              ),
            ],
          );
  }

  Future<String?> _promptDeviceName(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        void submit() => Navigator.of(context).pop(controller.text);
        return AlertDialog(
          title: const Text('Find Device by name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Name'),
            onSubmitted: (_) => submit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: submit,
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  Future<DeviceTrial?> _selectDeviceFromList(
      BuildContext context, List<DeviceTrial> devices) async {
    return showDialog<DeviceTrial>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Device'),
        children: devices
            .map(
              (device) => SimpleDialogOption(
                child: Text('${device.name} (ID: ${device.id})'),
                onPressed: () => Navigator.pop(context, device),
              ),
            )
            .toList(),
      ),
    );
  }
}
