import 'package:flutter/cupertino.dart';
import 'package:wifi_app/core/experiment/experiment_stage.dart';

class TestExperimentStage extends ExperimentStage<String> {
  TestExperimentStage({
    required super.id,
    required super.title,
    required super.description,
    super.pomaCommands = const {},
  });

  @override
  Widget buildWidget(
      BuildContext context, void Function(String result) onResult) {
    return const SizedBox();
  }
}
