import 'package:flutter/material.dart';
import '../../core/experiment/experiment_stage_feedback.dart';

class ExperimentStageFeedbackWidget<T_Result> extends StatefulWidget {
  final ExperimentStageFeedback<T_Result> stage;
  final void Function(T_Result result) onFeedback;

  const ExperimentStageFeedbackWidget({
    required ValueKey<String> super.key,
    required this.stage,
    required this.onFeedback,
  });

  @override
  ExperimentStageFeedbackWidgetState<T_Result> createState() =>
      ExperimentStageFeedbackWidgetState();
}

class ExperimentStageFeedbackWidgetState<T_Result>
    extends State<ExperimentStageFeedbackWidget<T_Result>> {
  bool _showScale = false;
  int _scaleSelectedValue = 0;

  void _onCompleteStage(int scaleFeedback) {
    widget.onFeedback(widget.stage.getResult(scaleFeedback));
    widget.stage.onExit();
  }

  @override
  void initState() {
    super.initState();
    widget.stage.onEnter();
    _scaleSelectedValue = widget.stage.initialSelectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_showScale) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _showScale = true),
              icon: Icon(widget.stage.positiveIcon, size: 32),
              label: Text(widget.stage.positiveLabel,
                  style: TextStyle(fontSize: 20)),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _onCompleteStage(widget.stage.minScaleValue),
              icon: Icon(widget.stage.negativeIcon, size: 32),
              label: Text(widget.stage.negativeLabel,
                  style: TextStyle(fontSize: 20)),
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("${widget.stage.feedbackLabel} $_scaleSelectedValue",
                textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
          ),
          Slider(
            value: _scaleSelectedValue.toDouble(),
            min: widget.stage.minScaleValue.toDouble(),
            max: widget.stage.maxScaleValue.toDouble(),
            divisions:
                (widget.stage.maxScaleValue - widget.stage.minScaleValue),
            label: _scaleSelectedValue.toString(),
            onChanged: (value) {
              setState(() {
                _scaleSelectedValue = value.toInt();
              });
            },
          ),
          SizedBox(height: 20),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _onCompleteStage(_scaleSelectedValue),
              icon: Icon(widget.stage.confirmIcon, size: 32),
              label: Text(widget.stage.confirmLabel,
                  style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ],
    );
  }
}
