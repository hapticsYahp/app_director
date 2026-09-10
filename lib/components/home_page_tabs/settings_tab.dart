import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo_dart;
import 'package:provider/provider.dart';
import 'package:yahp_director/components/ble_scan_dialog.dart';
import 'package:yahp_director/providers/poma/poma_exception.dart';
import '../../providers/config/config_notifier.dart';
import '../../providers/poma/poma_client.dart';
import '../../providers/poma/transport/ble_poma_transport.dart';
import '../../providers/poma/transport/poma_transport.dart';
import '../../providers/poma/transport/tcp_poma_transport.dart';

const String pomaTopicTest = "intensity";

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab>
    with AutomaticKeepAliveClientMixin {
  late final ConfigNotifier configNotifier;

  ConnectionType _connectionType = ConnectionType.tcp;

  bool isPomaTesting = false;
  String pomaTestResult = "";

  bool isDbTesting = false;
  String dbTestResult = "";

  final GlobalKey<FormState> _pomaFormKey = GlobalKey<FormState>();
  final _pomaHostController = TextEditingController();
  final _pomaPortController = TextEditingController();
  final _pomaMacController = TextEditingController();

  final GlobalKey<FormState> _dbFormKey = GlobalKey<FormState>();
  final _dbUriController = TextEditingController();

  bool get _isPomaFormValid {
    return _pomaFormKey.currentState?.validate() ?? false;
  }

  bool get _isDbFormValid {
    return _dbFormKey.currentState?.validate() ?? false;
  }

  bool get _isPomaFormChanged {
    if (!_isPomaFormValid) return false;
    if (_connectionType != configNotifier.connectionType) return true;
    if (_connectionType == ConnectionType.tcp) {
      return (_pomaHostController.text != configNotifier.deviceHost) ||
          (int.tryParse(_pomaPortController.text) != configNotifier.devicePort);
    } else {
      return _pomaMacController.text.trim() != configNotifier.deviceMac;
    }
  }

  bool get _isDbFormChanged {
    return _isDbFormValid && (_dbUriController.text != configNotifier.dbUri);
  }

  String? _validatePomaHost(String? host) {
    if (_connectionType != ConnectionType.tcp) {
      return null;
    }
    if ((host == null) || host.isEmpty || !TcpPomaTransport.isValidHost(host)) {
      return 'Invalid host; not a valid domain or IP address.';
    }
    return null;
  }

  String? _validatePomaPort(String? portString) {
    if (_connectionType != ConnectionType.tcp) {
      return null;
    }
    final port = int.tryParse(portString ?? "");
    if ((portString == null) ||
        portString.isEmpty ||
        (port == null) ||
        !TcpPomaTransport.isValidPort(port)) {
      return 'Invalid port; out of range (1-65535).';
    }
    return null;
  }

  String? _validatePomaMac(String? mac) {
    if (_connectionType != ConnectionType.ble) {
      return null;
    }
    if ((mac == null) ||
        mac.trim().isEmpty ||
        !BlePomaTransport.isValidMacOrId(mac.trim())) {
      return 'Invalid device MAC or UUID.';
    }
    return null;
  }

  Future<void> _onScanBleDevices() async {
    final device = await showBleScanDialog(context);
    if (!mounted) return;
    if (device != null) {
      setState(() {
        _pomaMacController.text = device.deviceId;
      });
    }
  }

  @override
  void dispose() {
    configNotifier.removeListener(_onConfigChanged);
    _pomaHostController.dispose();
    _pomaPortController.dispose();
    _pomaMacController.dispose();
    _dbUriController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    configNotifier = Provider.of<ConfigNotifier>(context, listen: false);
    _connectionType = configNotifier.connectionType;
    _pomaHostController.text = configNotifier.deviceHost;
    _pomaPortController.text = configNotifier.devicePort.toString();
    _pomaMacController.text = configNotifier.deviceMac;
    _dbUriController.text = configNotifier.dbUri;
    configNotifier.addListener(_onConfigChanged);
    super.initState();
  }

  void _onConfigChanged() {
    if (!mounted) return;
    if (_dbUriController.text.isEmpty && configNotifier.dbUri.isNotEmpty) {
      _dbUriController.text = configNotifier.dbUri;
    }
    if (_pomaHostController.text.isEmpty &&
        configNotifier.deviceHost.isNotEmpty) {
      _pomaHostController.text = configNotifier.deviceHost;
    }
    if (_pomaMacController.text.isEmpty &&
        configNotifier.deviceMac.isNotEmpty) {
      _pomaMacController.text = configNotifier.deviceMac;
    }
    if (_connectionType != configNotifier.connectionType) {
      setState(() {
        _connectionType = configNotifier.connectionType;
      });
    }
  }

  void _onPomaSave() {
    if (_isPomaFormValid && !isPomaTesting) {
      configNotifier.updateSettings(
        connectionType: _connectionType,
        deviceHost: _pomaHostController.text,
        devicePort:
            int.tryParse(_pomaPortController.text) ?? configNotifier.devicePort,
        deviceMac: _pomaMacController.text.trim(),
      );
      setState(() {
        pomaTestResult = "";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PoMA config saved.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onDbSave() {
    if (_isDbFormValid && !isDbTesting) {
      configNotifier.updateSettings(dbUri: _dbUriController.text);
      setState(() {
        dbTestResult = "";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('DB config saved.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onPomaTest() async {
    if (isPomaTesting || !_isPomaFormValid) {
      return;
    }
    if (_isPomaFormChanged) {
      _onPomaSave();
    }
    setState(() {
      isPomaTesting = true;
      pomaTestResult = "Testing PoMA connection...";
    });
    String result;
    PomaClient? pomaClient;
    try {
      final PomaTransport transport;
      if (configNotifier.connectionType == ConnectionType.ble) {
        transport = BlePomaTransport(
          deviceId: configNotifier.deviceMac,
          timeout: Duration(seconds: configNotifier.deviceConnectionTimeout),
        );
      } else {
        transport = TcpPomaTransport(
          host: configNotifier.deviceHost,
          port: configNotifier.devicePort,
          timeout: Duration(seconds: configNotifier.deviceConnectionTimeout),
        );
      }
      pomaClient = PomaClient(transport);
      pomaClient.responseTimeout = Duration(
        seconds: configNotifier.deviceConnectionTimeout,
      );
      await pomaClient.connect();
      List<String> topics = await pomaClient.getTopics();
      result = topics.contains(pomaTopicTest)
          ? "Success."
          : "Fail: PoMA device does not have '$pomaTopicTest' topic.";
    } on PomaException catch (e) {
      result = "PomaException: ${e.message}.";
    } catch (e) {
      result = "Error ${e.toString()}.";
    } finally {
      if (pomaClient != null) {
        await pomaClient.disconnect();
        await pomaClient.dispose();
      }
    }
    if (!mounted) return;
    setState(() {
      isPomaTesting = false;
      pomaTestResult = result;
    });
  }

  void _onDbTest() async {
    if (isDbTesting || !_isDbFormValid) {
      return;
    }
    if (_isDbFormChanged) {
      _onDbSave();
    }
    setState(() {
      isDbTesting = true;
      dbTestResult = "Testing DB connection...";
    });
    String result;
    mongo_dart.Db? db;
    try {
      db = await mongo_dart.Db.create(configNotifier.dbUri);
      await db.open().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Connection Timeout after 5s');
        },
      );
      final String testingCollectionName = "testing_haptic_collection";
      final String idColumn = "haptic_id";
      final int idVal = 123;
      final String testingColumn = "testing_column";
      final String testingVal = "testing_val";
      await db.createCollection(testingCollectionName);
      mongo_dart.DbCollection col = db.collection(testingCollectionName);
      await col.insertOne({idColumn: idVal, testingColumn: testingVal});
      Map<String, dynamic>? testFind = await col.findOne(
        mongo_dart.where.eq(idColumn, idVal).fields([testingColumn]),
      );
      final bool couldRet =
          (testFind != null) && (testFind[testingColumn] == testingVal);
      await db.dropCollection(testingCollectionName);
      result = couldRet ? "Success." : "Failed.";
    } catch (e) {
      result = "Error ${e.toString()}.";
    } finally {
      await db?.close();
    }
    if (!mounted) return;
    setState(() {
      isDbTesting = false;
      dbTestResult = result;
    });
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
            key: _pomaFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "PoMA Target",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SegmentedButton<ConnectionType>(
                    segments: const [
                      ButtonSegment<ConnectionType>(
                        value: ConnectionType.tcp,
                        label: Text("TCP"),
                        icon: Icon(Icons.lan),
                      ),
                      ButtonSegment<ConnectionType>(
                        value: ConnectionType.ble,
                        label: Text("BLE"),
                        icon: Icon(Icons.bluetooth),
                      ),
                    ],
                    selected: <ConnectionType>{_connectionType},
                    onSelectionChanged: (Set<ConnectionType> selection) {
                      setState(() {
                        _connectionType = selection.first;
                      });
                    },
                  ),
                ),
                if (_connectionType == ConnectionType.tcp)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _pomaHostController,
                          decoration: InputDecoration(
                            labelText: "Host",
                            hintText: "Ex: example.com, 192.168.0.100",
                          ),
                          validator: _validatePomaHost,
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
                          validator: _validatePomaPort,
                        ),
                      ),
                    ],
                  ),
                if (_connectionType == ConnectionType.ble)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _pomaMacController,
                          decoration: InputDecoration(
                            labelText: "MAC / Device ID",
                            hintText: "Ex: AA:BB:CC:DD:EE:FF",
                          ),
                          validator: _validatePomaMac,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: FilledButton.tonalIcon(
                          onPressed: _onScanBleDevices,
                          icon: const Icon(Icons.bluetooth_searching),
                          label: const Text("Scan"),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 24.0),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _onPomaSave,
                      child: Text("Save PoMA"),
                    ),
                    SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: _onPomaTest,
                      child: isPomaTesting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text("Test PoMA"),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(child: Text(pomaTestResult)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.0),
          Form(
            key: _dbFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "DB Server",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dbUriController,
                        decoration: InputDecoration(
                          labelText: "URI",
                          hintText: "Ex: mongodb://10.0.1.2:27017/db_name",
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Invalid URI.';
                          }
                          final uriRegExp = RegExp(
                            r'^(mongodb(\+srv)?):\/\/'
                            r'(?:[a-zA-Z0-9._%+-]+(?::[^@]+)?@)?'
                            r'([a-zA-Z0-9.-]+)'
                            r'(?::\d+)?'
                            r'(?:\/[a-zA-Z0-9_\-]+)?'
                            r'(?:\?.*)?$',
                          );
                          final match = uriRegExp.firstMatch(value);
                          if (match == null) {
                            return 'Invalid MongoDB URI.';
                          }
                          final isSrv = match.group(2) == '+srv';
                          final hasPort = value.contains(
                            RegExp(r'@[a-zA-Z0-9.-]+:\d+'),
                          );
                          if (isSrv && hasPort) {
                            return 'mongodb+srv URI must not include a port.';
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
                      onPressed: _onDbSave,
                      child: Text("Save DB"),
                    ),
                    SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: _onDbTest,
                      child: isDbTesting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text("Test DB"),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(child: Text(dbTestResult)),
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
