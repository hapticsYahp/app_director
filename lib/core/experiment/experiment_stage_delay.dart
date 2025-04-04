import 'package:flutter/material.dart';
import 'package:wifi_app/core/experiment/experiment_stage.dart';
import '../../components/experiment_stages/experiment_stage_delay_widget.dart';

class ExperimentStageDelay<T_Result> extends ExperimentStage<T_Result> {
  final T_Result completionResult;
  final int delaySeconds;
  final String delayFeedback;

  ExperimentStageDelay({
    required super.id,
    super.title = "Delay",
    super.description = "Delaying...",
    required this.completionResult,
    this.delaySeconds = 10,
    this.delayFeedback = "Starting in...",
    super.pomaCommands = const {},
  });

  @override
  Widget buildWidget(
    BuildContext context,
    void Function(T_Result result) onResult,
  ) {
    return ExperimentStageDelayWidget(
      key: ValueKey(id),
      stage: this,
      onComplete: onResult,
    );
  }
}
