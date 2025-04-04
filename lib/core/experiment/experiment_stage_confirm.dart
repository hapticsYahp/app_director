import 'package:flutter/material.dart';
import 'package:wifi_app/core/experiment/experiment_stage.dart';
import '../../components/experiment_stages/experiment_stage_confirm_widget.dart';

class ExperimentStageConfirm<T_Result> extends ExperimentStage<T_Result> {
  final T_Result confirmationResult;
  final String buttonLabel;
  final IconData buttonIcon;

  ExperimentStageConfirm({
    required super.id,
    super.title = "Confirm",
    super.description = "Please confirm.",
    required this.confirmationResult,
    this.buttonLabel = "Start",
    this.buttonIcon = Icons.play_arrow,
    super.pomaCommands = const {},
  });

  @override
  Widget buildWidget(
    BuildContext context,
    void Function(T_Result result) onResult,
  ) {
    return ExperimentStageConfirmWidget(
      key: ValueKey(id),
      stage: this,
      onConfirm: onResult,
    );
  }
}
