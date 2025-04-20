import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifi_app/providers/data/data_provider.dart';
import '../../core/experiment/experiment.dart';
import '../../providers/config/config_notifier.dart';
import '../../providers/poma/poma_client.dart';
import '../../providers/poma/poma_exception.dart';

class ExperimentsTab extends StatefulWidget {
  const ExperimentsTab({super.key});

  @override
  State<ExperimentsTab> createState() => _ExperimentsTabState();
}

class _ExperimentsTabState extends State<ExperimentsTab>
    with AutomaticKeepAliveClientMixin {
  late final DataProvider dataProvider;

  bool loadingExperiments = false;
  List<Experiment<String, String>> experiments = [];
  Experiment<String, String>? selectedExperiment;

  bool connectionCommandInProgress = false;
  late PomaClient pomaClient;

  @override
  void initState() {
    super.initState();
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    pomaClient = Provider.of<PomaClient>(context, listen: false);
    _getExperiments();
  }

  Future<void> _getExperiments() async {
    if (!loadingExperiments) {
      setState(() {
        loadingExperiments = true;
      });
      try {
        final result = await dataProvider.getExperiments();
        setState(() {
          experiments = result;
        });
      } catch (e, stackTrace) {
        debugPrint("Error: $e");
        debugPrintStack(stackTrace: stackTrace);
        _showAlert("Error", e.toString());
      } finally {
        setState(() {
          loadingExperiments = false;
        });
      }
    }
  }

  void _onConnect() async {
    if (!connectionCommandInProgress && !pomaClient.isConnected()) {
      final ConfigNotifier configNotifier =
          Provider.of<ConfigNotifier>(context, listen: false);
      setState(() {
        connectionCommandInProgress = true;
      });
      try {
        await pomaClient.connect(
          configNotifier.deviceHost,
          configNotifier.devicePort,
          timeout: Duration(seconds: configNotifier.deviceConnectionTimeout),
        );
      } on PomaException catch (e, stackTrace) {
        debugPrint("PoMA Exception: $e");
        debugPrintStack(stackTrace: stackTrace);
        _showAlert("PoMA Exception", e.message);
      } catch (e, stackTrace) {
        debugPrint("Error: $e");
        debugPrintStack(stackTrace: stackTrace);
        _showAlert("Error", e.toString());
      }
      setState(() {
        connectionCommandInProgress = false;
      });
    }
  }

  void _onDisconnect() async {
    if (!connectionCommandInProgress && pomaClient.isConnected()) {
      setState(() {
        connectionCommandInProgress = true;
      });
      try {
        await pomaClient.disconnect();
      } on PomaException catch (e, stackTrace) {
        debugPrint("PoMA Exception: $e");
        debugPrintStack(stackTrace: stackTrace);
        _showAlert("PoMA Exception", e.message);
      } catch (e, stackTrace) {
        debugPrint("Error: $e");
        debugPrintStack(stackTrace: stackTrace);
        _showAlert("Error", e.toString());
      }
      setState(() {
        connectionCommandInProgress = false;
      });
    }
  }

  void _showAlert(String title, String value) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(value),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _onStageResult(String result) {
    setState(() {
      selectedExperiment?.advanceByResult(result);
    });
  }

  void _onCancel() {
    setState(() {
      selectedExperiment?.abort();
    });
  }

  void _onClose() {
    setState(() {
      selectedExperiment?.reset();
      selectedExperiment = null;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: pomaClient.isConnected() ? _onDisconnect : _onConnect,
              icon: Icon(
                  pomaClient.isConnected() ? Icons.sensors_off : Icons.sensors),
              label: connectionCommandInProgress
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(pomaClient.isConnected() ? "Disconnect" : "Connect"),
            ),
            SizedBox(
              width: 16,
            ),
            ElevatedButton.icon(
              onPressed: _getExperiments,
              icon: Icon(Icons.refresh),
              label: loadingExperiments
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text("Experiments"),
            ),
          ],
        ),
        ...((selectedExperiment == null)
            // Experiments selection.
            ? [
                DropdownButtonFormField<Experiment<String, String>>(
                  decoration: InputDecoration(
                    labelText: "Experiment",
                    hintText: "Select experiment to run",
                  ),
                  value: selectedExperiment,
                  items: experiments
                      .map<DropdownMenuItem<Experiment<String, String>>>(
                          (Experiment<String, String> value) {
                    return DropdownMenuItem<Experiment<String, String>>(
                      value: value,
                      child: Text(value.title),
                    );
                  }).toList(),
                  onChanged: (Experiment<String, String>? value) {
                    if (value != null) {
                      value.setPomaClient(pomaClient);
                    }
                    setState(() {
                      selectedExperiment = value;
                    });
                  },
                  validator: (Experiment? value) {
                    if (value == null) {
                      return 'Please select.';
                    }
                    return null;
                  },
                ),
              ]
            : [
                // Experiment title & description.
                Text(
                  selectedExperiment!.title,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  selectedExperiment!.description,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
/*
          // Experiment progress feedback.
          Center(
            child: Text(
              "Stage #${experiment.stageIndex} (of ${experiment.stagesCount})",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
              value: experiment.stageIndex / experiment.stagesCount),
          SizedBox(height: 16),
*/
                // Current Stage title & description.
                Text(
                  selectedExperiment!.currentStage.title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  selectedExperiment!.currentStage.description,
                ),
                SizedBox(height: 16),

                // Current Stage content.
                Expanded(
                  child: Center(
                    child: selectedExperiment!.currentStage
                        .buildWidget(context, _onStageResult),
                  ),
                ),
                SizedBox(height: 24),

                // Cancel Experiment on any Stage.
                Center(
                  child: selectedExperiment!.canAdvance
                      ? ElevatedButton.icon(
                          onPressed: _onCancel,
                          icon: Icon(Icons.cancel),
                          label: Text("Cancel"),
                        )
                      : ElevatedButton(
                          onPressed: _onClose,
                          child: Text("Close"),
                        ),
                ),
              ]),
      ]),
    );
  }
}
