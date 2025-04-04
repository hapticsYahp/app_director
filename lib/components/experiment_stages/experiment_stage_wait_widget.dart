import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/experiment/experiment_stage_wait.dart';

class ExperimentStageWaitWidget<T_Result> extends StatefulWidget {
  final ExperimentStageWait<T_Result> stage;
  final void Function(T_Result result) onComplete;

  const ExperimentStageWaitWidget({
    required ValueKey<String> super.key,
    required this.stage,
    required this.onComplete,
  });

  @override
  ExperimentStageWaitWidgetState<T_Result> createState() =>
      ExperimentStageWaitWidgetState();
}

class ExperimentStageWaitWidgetState<T_Result>
    extends State<ExperimentStageWaitWidget<T_Result>> {
  Timer? _timer;
  double _progress = 0;
  int _remainingTime = 0;
  bool _stageCompleted = false;

  @override
  void initState() {
    super.initState();
    _startStage();
  }

  @override
  void didUpdateWidget(
      covariant ExperimentStageWaitWidget<T_Result> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stage != oldWidget.stage) {
      _startStage();
    }
  }

  void _startStage() {
    widget.stage.onEnter();
    setState(() {
      _stageCompleted = false;
    });
    _resetTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    _remainingTime = widget.stage.waitingSeconds;
    _progress = 0;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
          _progress = (widget.stage.waitingSeconds - _remainingTime) /
              widget.stage.waitingSeconds;
        });
        widget.stage.onTick(widget.stage.waitingSeconds - _remainingTime);
      } else {
        _onTimeout();
      }
    });
  }

  void _onTimeout() {
    widget.onComplete(widget.stage.timeoutResult);
    _onCompleteStage();
  }

  void _onFeedback() {
    widget.onComplete(widget.stage.feedbackResult);
    _onCompleteStage();
  }

  void _onCompleteStage() {
    if (!_stageCompleted) {
      _stageCompleted = true;
      _timer?.cancel();
      widget.stage.onExit();
    }
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "${widget.stage.waitFeedback} ${_remainingTime}s",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 20),
        LinearProgressIndicator(value: _progress, minHeight: 10),
        SizedBox(height: 20),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _stageCompleted ? null : _onFeedback,
            icon: Icon(widget.stage.buttonIcon, size: 32),
            label: Text(
              widget.stage.buttonLabel,
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }
}
