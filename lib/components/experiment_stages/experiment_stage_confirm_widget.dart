import 'package:flutter/material.dart';
import '../../core/experiment/experiment_stage_confirm.dart';

class ExperimentStageConfirmWidget<T_Result> extends StatelessWidget {
  final ExperimentStageConfirm<T_Result> stage;
  final void Function(T_Result result) onConfirm;

  const ExperimentStageConfirmWidget({
    required ValueKey<String> super.key,
    required this.stage,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ElevatedButton.icon(
        icon: Icon(stage.buttonIcon, size: 32),
        label: Text(stage.buttonLabel, style: const TextStyle(fontSize: 20)),
        onPressed: () => onConfirm(stage.confirmationResult),
      ),
    );
  }
}
