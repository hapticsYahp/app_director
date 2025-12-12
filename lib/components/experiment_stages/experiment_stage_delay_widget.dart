import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/experiment/experiment_stage_delay.dart';

class ExperimentStageDelayWidget<T_Result> extends StatefulWidget {
  final ExperimentStageDelay<T_Result> stage;
  final void Function(T_Result result) onComplete;

  const ExperimentStageDelayWidget({
    required ValueKey<String> super.key,
    required this.stage,
    required this.onComplete,
  });

  @override
  ExperimentStageDelayWidgetState<T_Result> createState() =>
      ExperimentStageDelayWidgetState();
}

class ExperimentStageDelayWidgetState<T_Result>
    extends State<ExperimentStageDelayWidget<T_Result>> {
  Timer? _timer;
  double _progress = 0;
  int _remainingTimeMs = 0;

  @override
  void initState() {
    super.initState();
    _startStage();
  }

  @override
  void didUpdateWidget(
      covariant ExperimentStageDelayWidget<T_Result> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stage != oldWidget.stage) {
      _startStage();
    }
  }

  void _startStage() {
    widget.stage.onEnter();
    _resetTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    _remainingTimeMs = widget.stage.delayMs;
    _progress = 0;

    _timer = Timer.periodic(Duration(milliseconds: widget.stage.tickProgressMs),
        (timer) {
      if (_remainingTimeMs > 0) {
        setState(() {
          _remainingTimeMs = _remainingTimeMs - widget.stage.tickProgressMs;
          _progress =
              (widget.stage.delayMs - _remainingTimeMs) / widget.stage.delayMs;
        });
        widget.stage.onTick(widget.stage.delayMs - _remainingTimeMs);
      } else {
        _timer?.cancel();
        _onCompleteStage();
      }
    });
  }

  void _onCompleteStage() {
    widget.onComplete(widget.stage.completionResult);
    widget.stage.onExit();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.stage.showProgressBar) ...[
          Text(
              "${widget.stage.delayFeedback} ${(_remainingTimeMs / 1000).ceil()}s...",
              style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          LinearProgressIndicator(value: _progress, minHeight: 10),
        ],
      ],
    );
  }
}
