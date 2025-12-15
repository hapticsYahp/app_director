import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo_dart;
import 'package:provider/provider.dart';
import 'package:yahp_director/providers/poma/poma_exception.dart';
import '../../providers/config/config_notifier.dart';
import '../../providers/poma/poma_client.dart';
import '../../providers/poma/poma_socket_impl.dart';

const String pomaTopicTest = "intensity";

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab>
    with AutomaticKeepAliveClientMixin {
  late final ConfigNotifier configNotifier;

  bool isPomaTesting = false;
  String pomaTestResult = "";

  bool isDbTesting = false;
  String dbTestResult = "";

  final GlobalKey<FormState> _pomaFormKey = GlobalKey<FormState>();
  final _pomaHostController = TextEditingController();
  final _pomaPortController = TextEditingController();

  final GlobalKey<FormState> _dbFormKey = GlobalKey<FormState>();
  final _dbUriController = TextEditingController();

  bool get _isPomaFormValid {
    return _pomaFormKey.currentState?.validate() ?? false;
  }

  bool get _isDbFormValid {
    return _dbFormKey.currentState?.validate() ?? false;
  }

  bool get _isPomaFormChanged {
    return _isPomaFormValid &&
        ((_pomaHostController.text != configNotifier.deviceHost) ||
            (int.tryParse(_pomaPortController.text) !=
                configNotifier.devicePort));
  }

  bool get _isDbFormChanged {
    return _isDbFormValid && (_dbUriController.text != configNotifier.dbUri);
  }

  @override
  void dispose() {
    _pomaHostController.dispose();
    _pomaPortController.dispose();
    _dbUriController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    configNotifier = Provider.of<ConfigNotifier>(context, listen: false);
    _pomaHostController.text = configNotifier.deviceHost;
    _pomaPortController.text = configNotifier.devicePort.toString();
    _dbUriController.text = configNotifier.dbUri;
    super.initState();
  }

  void _onPomaSave() {
    if (_isPomaFormValid && !isPomaTesting) {
      configNotifier.updateSettings(
        deviceHost: _pomaHostController.text,
        devicePort: int.tryParse(_pomaPortController.text)!,
      );
      setState(() {
        pomaTestResult = "";
      });
    }
  }

  void _onDbSave() {
    if (_isDbFormValid && !isDbTesting) {
      configNotifier.updateSettings(
        dbUri: _dbUriController.text,
      );
      setState(() {
        dbTestResult = "";
      });
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
    try {
      PomaClient pomaClient = PomaClient(PomaSocketImpl());
      await pomaClient.connect(
        configNotifier.deviceHost,
        configNotifier.devicePort,
      );
      List<String> topics = await pomaClient.getTopics();
      result = topics.contains(pomaTopicTest)
          ? "Success."
          : "Fail: PoMA device does not have '$pomaTopicTest' topic.";
      await pomaClient.disconnect();
    } on PomaException catch (e) {
      result = "PomaException: ${e.message}.";
    } catch (e) {
      result = "Error ${e.toString()}.";
    }
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
    try {
      mongo_dart.Db db = await mongo_dart.Db.create(configNotifier.dbUri);
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
      db.createCollection(testingCollectionName);
      mongo_dart.DbCollection col = db.collection(testingCollectionName);
      await col.insertOne({idColumn: idVal, testingColumn: testingVal});
      Map<String, dynamic>? testFind = await col.findOne(
          mongo_dart.where.eq(idColumn, idVal).fields([testingColumn]));
      final bool couldRet =
          (testFind != null) && (testFind[testingColumn] == testingVal);
      await db.dropCollection(testingCollectionName);
      await db.close();
      result = couldRet ? "Succes." : "Failed.";
    } catch (e) {
      result = "Error ${e.toString()}.";
    }
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
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text("Test PoMA"),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Text(pomaTestResult),
                    ),
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
                          final uriRegExp = RegExp(r'^(mongodb(\+srv)?):\/\/'
                              r'(?:[a-zA-Z0-9._%+-]+(?::[^@]+)?@)?'
                              r'([a-zA-Z0-9.-]+)'
                              r'(?::\d+)?'
                              r'(?:\/[a-zA-Z0-9_\-]+)?'
                              r'(?:\?.*)?$');
                          final match = uriRegExp.firstMatch(value);
                          if (match == null) {
                            return 'Invalid MongoDB URI.';
                          }
                          final isSrv = match.group(2) == '+srv';
                          final hasPort =
                              value.contains(RegExp(r'@[a-zA-Z0-9.-]+:\d+'));
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
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text("Test DB"),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Text(dbTestResult),
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
