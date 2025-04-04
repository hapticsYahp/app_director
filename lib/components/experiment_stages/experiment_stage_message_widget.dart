import 'package:flutter/material.dart';
import '../../core/experiment/experiment_stage_message.dart';

class ExperimentStageMessageWidget<T_Result> extends StatefulWidget {
  final ExperimentStageMessage<T_Result> stage;
  final void Function(T_Result result) onComplete;

  const ExperimentStageMessageWidget({
    required ValueKey<String> super.key,
    required this.stage,
    required this.onComplete,
  });

  @override
  ExperimentStageMessageWidgetState<T_Result> createState() =>
      ExperimentStageMessageWidgetState();
}

class ExperimentStageMessageWidgetState<T_Result>
    extends State<ExperimentStageMessageWidget<T_Result>> {
  @override
  void initState() {
    super.initState();
    widget.stage.onEnter();
  }

  @override
  void dispose() {
    super.dispose();
    if (!mounted) {
      debugPrint("NOT MOUNTED");
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onComplete(widget.stage.exitedResult);
    });
  }

  @override
  void didUpdateWidget(
      covariant ExperimentStageMessageWidget<T_Result> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stage != oldWidget.stage) {
      widget.stage.onEnter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          widget.stage.message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
