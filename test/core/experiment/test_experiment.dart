import 'package:wifi_app/core/experiment/experiment.dart';

class TestExperiment extends Experiment<String, String> {
  TestExperiment({
    required super.id,
    required super.title,
    required super.description,
    required super.stages,
    required super.transitions,
    super.initialStageId,
    super.lastStageId,
    super.cancelStageId,
  });
}
