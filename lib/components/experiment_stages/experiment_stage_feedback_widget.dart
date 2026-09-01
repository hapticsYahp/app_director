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
  late int _scaleSelectedValue;

  int get _effectiveMin =>
      widget.stage.minScaleValue <= widget.stage.maxScaleValue
          ? widget.stage.minScaleValue
          : widget.stage.maxScaleValue;

  int get _effectiveMax =>
      widget.stage.minScaleValue <= widget.stage.maxScaleValue
          ? widget.stage.maxScaleValue
          : widget.stage.minScaleValue;

  int get _divisions => _effectiveMax - _effectiveMin;

  void _onCompleteStage(int scaleFeedback) {
    widget.onFeedback(widget.stage.getResult(scaleFeedback));
  }

  @override
  void initState() {
    super.initState();
    _scaleSelectedValue =
        widget.stage.initialSelectedValue.clamp(_effectiveMin, _effectiveMax);
  }

  @override
  void didUpdateWidget(
    covariant ExperimentStageFeedbackWidget<T_Result> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    _scaleSelectedValue =
        _scaleSelectedValue.clamp(_effectiveMin, _effectiveMax);
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
              label: Text(
                widget.stage.positiveLabel,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _onCompleteStage(_effectiveMin),
              icon: Icon(widget.stage.negativeIcon, size: 32),
              label: Text(
                widget.stage.negativeLabel,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "${widget.stage.feedbackLabel} $_scaleSelectedValue",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          Slider(
            value: _scaleSelectedValue
                .clamp(_effectiveMin, _effectiveMax)
                .toDouble(),
            min: _effectiveMin.toDouble(),
            max: _effectiveMax.toDouble(),
            divisions: _divisions > 0 ? _divisions : null,
            label: _scaleSelectedValue.toString(),
            onChanged: _divisions > 0
                ? (value) {
                    setState(() {
                      _scaleSelectedValue =
                          value.round().clamp(_effectiveMin, _effectiveMax);
                    });
                  }
                : null,
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _onCompleteStage(_scaleSelectedValue),
              icon: Icon(widget.stage.confirmIcon, size: 32),
              label: Text(
                widget.stage.confirmLabel,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
