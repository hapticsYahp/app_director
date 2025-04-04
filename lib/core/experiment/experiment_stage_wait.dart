import 'package:flutter/material.dart';
import 'package:wifi_app/core/experiment/experiment_stage.dart';

import '../../components/experiment_stages/experiment_stage_wait_widget.dart';

class ExperimentStageWait<T_Result> extends ExperimentStage<T_Result> {
  final T_Result timeoutResult;
  final T_Result feedbackResult;
  final int waitingSeconds;
  final String waitFeedback;
  final String buttonLabel;
  final IconData buttonIcon;

  ExperimentStageWait({
    required super.id,
    super.title = "Wait",
    super.description = "Waiting...",
    required this.timeoutResult,
    required this.feedbackResult,
    this.waitingSeconds = 10,
    this.waitFeedback = "Time:",
    this.buttonLabel = "Feedback",
    this.buttonIcon = Icons.thumb_up,
    super.pomaCommands = const {},
  });

  @override
  Widget buildWidget(
    BuildContext context,
    void Function(T_Result result) onResult,
  ) {
    return ExperimentStageWaitWidget(
      key: ValueKey(id),
      stage: this,
      onComplete: onResult,
    );
  }
}
