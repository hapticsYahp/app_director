import 'package:flutter/material.dart';
import 'package:wifi_app/providers/poma/poma_exception.dart';

import '../../providers/poma/poma_client.dart';
import '../../providers/poma/poma_socket_impl.dart';

const String defaultPomaHost = "172.24.149.223";
const int defaultPomaPort = 3333;
const String pomaTopicTest = "intensity";

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab>
    with AutomaticKeepAliveClientMixin {
  String pomaHost = defaultPomaHost;
  int pomaPort = defaultPomaPort;

  bool isTesting = false;
  String testResult = "";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _pomaHostController = TextEditingController();
  final _pomaPortController = TextEditingController();

  @override
  void dispose() {
    _pomaHostController.dispose();
    _pomaPortController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _pomaHostController.text = pomaHost;
    _pomaPortController.text = pomaPort.toString();
    super.initState();
  }

  void _onSave() {
    if (_isFormValid && !isTesting) {
      setState(() {
        pomaHost = _pomaHostController.text;
        pomaPort = int.tryParse(_pomaPortController.text)!;
        testResult = "";
      });
    }
  }

  void _onTest() async {
    if (isTesting || !_isFormValid) {
      return;
    }
    setState(() {
      isTesting = true;
      testResult = "Testing...";
    });
    String result;
    try {
      PomaClient pomaClient = PomaClient(PomaSocketImpl());
      await pomaClient.connect(pomaHost, pomaPort);
      List<String> topics = await pomaClient.getTopics();
      result = topics.contains(pomaTopicTest)
          ? "Success."
          : "Fail: PoMA device does not have '$pomaTopicTest' topic.";
    } on PomaException catch (e) {
      result = "PomaException: ${e.message}.";
    } catch (e) {
      result = "Error: ${e.toString()}.";
    }
    setState(() {
      isTesting = false;
      testResult = result;
    });
  }

  bool get _isFormValid {
    return _formKey.currentState?.validate() ?? false;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "PoMA Server",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _pomaHostController,
                        decoration: InputDecoration(
                          labelText: "Host",
                          hintText: "Ex: example.com, 192.168.0.100",
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Invalid host.';
                          }
                          final RegExp ipv4RegExp =
                              RegExp(r'^(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.'
                                  r'(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.'
                                  r'(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.'
                                  r'(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)$');
                          final RegExp domainRegExp = RegExp(
                              r'^(localhost|(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,})$');
                          if (!ipv4RegExp.hasMatch(value) &&
                              !domainRegExp.hasMatch(value)) {
                            return 'Invalid host; not a valid domain or IP address.';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: TextFormField(
                        controller: _pomaPortController,
                        decoration: InputDecoration(
                          labelText: "Port",
                          hintText: "Ex: 3333",
                        ),
                        keyboardType: TextInputType.number,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Invalid port.';
                          }
                          final port = int.tryParse(value);
                          if (port == null || port < 1 || port > 65535) {
                            return 'Invalid port; out of range (1-65535).';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.0),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _onSave,
                      child: Text("Save"),
                    ),
                    SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: _onTest,
                      child: isTesting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text("Test"),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Text(testResult),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
