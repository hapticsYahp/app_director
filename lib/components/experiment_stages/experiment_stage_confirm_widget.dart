import 'package:flutter/material.dart';
import '../../core/experiment/experiment_stage_confirm.dart';

class ExperimentStageConfirmWidget<T_Result> extends StatefulWidget {
  final ExperimentStageConfirm<T_Result> stage;
  final void Function(T_Result result) onConfirm;

  const ExperimentStageConfirmWidget({
    required ValueKey<String> super.key,
    required this.stage,
    required this.onConfirm,
  });

  @override
  ExperimentStageConfirmWidgetState<T_Result> createState() =>
      ExperimentStageConfirmWidgetState();
}

class ExperimentStageConfirmWidgetState<T_Result>
    extends State<ExperimentStageConfirmWidget<T_Result>> {
  @override
  void initState() {
    super.initState();
    widget.stage.onEnter();
  }

  void _onConfirm() {
    widget.onConfirm(widget.stage.confirmationResult);
    widget.stage.onExit();
  }

  @override
  void didUpdateWidget(
      covariant ExperimentStageConfirmWidget<T_Result> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stage != oldWidget.stage) {
      widget.stage.onEnter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ElevatedButton.icon(
        icon: Icon(widget.stage.buttonIcon, size: 32),
        label: Text(widget.stage.buttonLabel, style: TextStyle(fontSize: 20)),
        onPressed: _onConfirm,
      ),
    );
  }
}
