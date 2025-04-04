import 'package:flutter/material.dart';
import 'package:wifi_app/core/experiment/experiment_stage.dart';
import '../../components/experiment_stages/experiment_stage_message_widget.dart';

class ExperimentStageMessage<T_Result> extends ExperimentStage<T_Result> {
  final T_Result exitedResult;
  final String message;

  ExperimentStageMessage({
    required super.id,
    super.title = "Message",
    super.description = "",
    required this.exitedResult,
    this.message = "Thank you.",
    super.pomaCommands = const {},
  });

  @override
  Widget buildWidget(
    BuildContext context,
    void Function(T_Result result) onResult,
  ) {
    return ExperimentStageMessageWidget(
      key: ValueKey(id),
      stage: this,
      onComplete: onResult,
    );
  }
}
