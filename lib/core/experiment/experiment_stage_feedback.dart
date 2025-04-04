import 'package:flutter/material.dart';
import 'package:wifi_app/core/experiment/experiment_stage.dart';
import '../../components/experiment_stages/experiment_stage_feedback_widget.dart';

class ExperimentStageFeedback<T_Result> extends ExperimentStage<T_Result> {
  final int minScaleValue;
  final int maxScaleValue;
  final int initialSelectedValue;
  final String positiveLabel;
  final String negativeLabel;
  final String feedbackLabel;
  final String confirmLabel;
  final T_Result Function(int sacaleValue) getResult;
  final IconData positiveIcon;
  final IconData negativeIcon;
  final IconData confirmIcon;

  ExperimentStageFeedback({
    required super.id,
    super.title = "Feedback",
    super.description = "Please provide your feedback.",
    this.minScaleValue = 0,
    this.maxScaleValue = 10,
    this.initialSelectedValue = 5,
    this.positiveLabel = "Yes",
    this.negativeLabel = "No",
    this.feedbackLabel = "Indicate the perceived intensity:",
    this.confirmLabel = "Confirm",
    required this.getResult,
    this.positiveIcon = Icons.thumb_up,
    this.negativeIcon = Icons.thumb_down,
    this.confirmIcon = Icons.check,
    super.pomaCommands = const {},
  });

  @override
  Widget buildWidget(
    BuildContext context,
    void Function(T_Result result) onResult,
  ) {
    return ExperimentStageFeedbackWidget(
      key: ValueKey(id),
      stage: this,
      onFeedback: onResult,
    );
  }
}
