import 'package:flutter/material.dart';
import 'package:wifi_app/providers/data/data_provider.dart';
import '../../core/experiment/experiment.dart';

class ExperimentsTab extends StatefulWidget {
  const ExperimentsTab({super.key});

  @override
  State<ExperimentsTab> createState() => _ExperimentsTabState();
}

class _ExperimentsTabState extends State<ExperimentsTab>
    with AutomaticKeepAliveClientMixin {
  late List<Experiment<String, String>> experiments;
  Experiment<String, String>? selectedExperiment;

  @override
  void initState() {
    super.initState();
    experiments = DataProvider().getExperiments();
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: (selectedExperiment == null)
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
              ],
      ),
    );
  }
}
