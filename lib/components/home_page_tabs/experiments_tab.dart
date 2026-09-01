import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yahp_director/providers/data/data_provider.dart';
import '../../core/experiment/experiment.dart';
import '../../core/trial/experiment_trial.dart';
import '../../providers/config/device_trial_notifier.dart';
import '../../providers/config/subject_trial_notifier.dart';
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

  @override
  void dispose() {
    selectedExperiment?.removeListener(_onExperimentUpdate);
    super.dispose();
  }

  Future<void> _getExperiments() async {
    if (!loadingExperiments) {
      setState(() {
        loadingExperiments = true;
      });
      try {
        final result = await dataProvider.getExperiments();
        if (!mounted) return;
        setState(() {
          experiments = result;
        });
      } catch (e, stackTrace) {
        debugPrint("Error: $e");
        debugPrintStack(stackTrace: stackTrace);
        if (!mounted) return;
        _showAlert("Error", e.toString());
      } finally {
        if (mounted) {
          setState(() {
            loadingExperiments = false;
          });
        }
      }
    }
  }

  void _onConnect() async {
    if (!connectionCommandInProgress && !pomaClient.isConnected()) {
      setState(() {
        connectionCommandInProgress = true;
      });
      try {
        await pomaClient.connect();
      } on PomaException catch (e, stackTrace) {
        debugPrint("PoMA Exception: $e");
        debugPrintStack(stackTrace: stackTrace);
        if (mounted) {
          _showAlert("PoMA Exception", e.message);
        }
      } catch (e, stackTrace) {
        debugPrint("Error: $e");
        debugPrintStack(stackTrace: stackTrace);
        if (mounted) {
          _showAlert("Error", e.toString());
        }
      } finally {
        if (mounted) {
          setState(() {
            connectionCommandInProgress = false;
          });
        }
      }
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
        if (mounted) {
          _showAlert("PoMA Exception", e.message);
        }
      } catch (e, stackTrace) {
        debugPrint("Error: $e");
        debugPrintStack(stackTrace: stackTrace);
        if (mounted) {
          _showAlert("Error", e.toString());
        }
      } finally {
        if (mounted) {
          setState(() {
            connectionCommandInProgress = false;
          });
        }
      }
    }
  }

  void _showAlert(String title, String value) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(value),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _onStageResult(String result) {
    selectedExperiment?.advanceByResult(result);
  }

  void _onCancel() {
    selectedExperiment?.abort();
  }

  void _onExperimentUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onClose() async {
    selectedExperiment?.removeListener(_onExperimentUpdate);
    ExperimentTrial? trial = selectedExperiment?.end();
    if (trial != null) {
      await dataProvider.saveTrialEvents(trial);
    }
    if (!mounted) return;
    setState(() {
      selectedExperiment = null;
    });
  }

  Future<void> _onSelectExperiment(
      Experiment<String, String>? experiment) async {
    selectedExperiment?.removeListener(_onExperimentUpdate);
    if (experiment != null) {
      final selectedSubject =
          Provider.of<SubjectTrialNotifier>(context, listen: false)
              .selectedSubject;
      final selectedDevice =
          Provider.of<DeviceTrialNotifier>(context, listen: false)
              .selectedDevice;
      if ((selectedSubject == null) || (selectedDevice == null)) {
        experiment = null;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Select Device/Subject first.')),
          );
        }
      } else {
        final trial = await dataProvider.createTrial(
            experiment, selectedSubject, selectedDevice);
        if (!mounted) return;
        experiment.setPomaClient(pomaClient);
        experiment.addListener(_onExperimentUpdate);
        experiment.start(trial);
      }
    }
    if (!mounted) return;
    setState(() {
      selectedExperiment = experiment;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.watch<SubjectTrialNotifier>();
    context.watch<DeviceTrialNotifier>();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(
          // FIXME: disconnect PoMA on device change. Disable connection if selectedDevice is null.
          child: ElevatedButton.icon(
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
        ),
        Divider(color: Colors.grey, thickness: 1, indent: 0, endIndent: 0),
        Center(
          child: ElevatedButton.icon(
            onPressed: _getExperiments,
            icon: Icon(Icons.refresh),
            label: loadingExperiments
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text("Reload Experiments"),
          ),
        ),
        ...((selectedExperiment == null)
            ? [
                // Experiments selection.
                DropdownButtonFormField<Experiment<String, String>>(
                  decoration: InputDecoration(
                    labelText: "Experiment",
                    hintText: "Select experiment to run",
                  ),
                  initialValue: selectedExperiment,
                  items: experiments
                      .map<DropdownMenuItem<Experiment<String, String>>>(
                          (Experiment<String, String> value) {
                    return DropdownMenuItem<Experiment<String, String>>(
                      value: value,
                      child: Text(value.title),
                    );
                  }).toList(),
                  onChanged: (Experiment<String, String>? experiment) async {
                    await _onSelectExperiment(experiment);
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
