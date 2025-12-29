import 'package:flutter/material.dart';
import '../../core/experiment/experiment_stage_shuffle.dart';

class ExperimentStageShuffleWidget<T_Result> extends StatefulWidget {
  final ExperimentStageShuffle<T_Result> stage;
  final void Function(T_Result result) onComplete;

  const ExperimentStageShuffleWidget({
    required ValueKey<String> super.key,
    required this.stage,
    required this.onComplete,
  });

  @override
  ExperimentStageShuffleWidgetState<T_Result> createState() =>
      ExperimentStageShuffleWidgetState();
}

class ExperimentStageShuffleWidgetState<T_Result>
    extends State<ExperimentStageShuffleWidget<T_Result>> {
  @override
  void initState() {
    super.initState();
    widget.stage.onEnter();
    _handleShuffle();
  }

  void _handleShuffle() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (widget.stage.hasNextStage()) {
        widget.stage.experiment?.advanceToStage(widget.stage.getNextStageId());
      } else {
        widget.onComplete(widget.stage.completionResult);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
