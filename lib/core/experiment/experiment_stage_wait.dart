import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wifi_app/core/experiment/experiment_stage.dart';
import '../../components/experiment_stages/experiment_stage_wait_widget.dart';
import '../serialization/icon_data_json_converter.dart';

part 'experiment_stage_wait.g.dart';

@JsonSerializable(genericArgumentFactories: true)
@IconDataJsonConverter()
class ExperimentStageWait<T_Result> extends ExperimentStage<T_Result> {
  static const String jsonType = 'wait';

  final T_Result timeoutResult;
  final T_Result feedbackResult;
  final int waitingMs;
  final int tickProgressMs;
  final String waitFeedback;
  final String buttonLabel;
  final IconData buttonIcon;
  final bool showProgressBar;

  ExperimentStageWait({
    required super.id,
    super.title = "Wait",
    super.description = "Waiting...",
    required this.timeoutResult,
    required this.feedbackResult,
    this.waitingMs = 10_000,
    this.tickProgressMs = 100,
    this.waitFeedback = "Time:",
    this.buttonLabel = "Feedback",
    this.buttonIcon = Icons.thumb_up,
    this.showProgressBar = true,
    super.pomaCommands = const {},
  });

  @override
  Widget buildWidget(
    BuildContext context,
    void Function(T_Result result) onResult,
  ) {
    return ExperimentStageWaitWidget(
      key: ValueKey(id),
      stage: this,
      onComplete: onResult,
    );
  }

  factory ExperimentStageWait.fromJson(
    Map<String, dynamic> json,
    T_Result Function(Object? json) fromJsonTResult,
  ) =>
      _$ExperimentStageWaitFromJson(json, fromJsonTResult);

  @override
  Map<String, dynamic> toJson(Object? Function(T_Result value) toJsonTResult) =>
      _$ExperimentStageWaitToJson(this, toJsonTResult);

  @override
  String getJsonType() {
    return jsonType;
  }
}
