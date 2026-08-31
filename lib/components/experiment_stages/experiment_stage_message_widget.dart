import 'package:flutter/material.dart';
import '../../core/experiment/experiment_stage_message.dart';

class ExperimentStageMessageWidget<T_Result> extends StatelessWidget {
  final ExperimentStageMessage<T_Result> stage;
  final void Function(T_Result result) onComplete;

  const ExperimentStageMessageWidget({
    required ValueKey<String> super.key,
    required this.stage,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          stage.message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
