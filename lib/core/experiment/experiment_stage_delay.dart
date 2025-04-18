import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wifi_app/core/experiment/experiment_stage.dart';
import '../../components/experiment_stages/experiment_stage_delay_widget.dart';

part 'experiment_stage_delay.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ExperimentStageDelay<T_Result> extends ExperimentStage<T_Result> {
  static const String jsonType = 'delay';

  final T_Result completionResult;
  final int delayMs;
  final int tickProgressMs;
  final String delayFeedback;

  ExperimentStageDelay({
    required super.id,
    super.title = "Delay",
    super.description = "Delaying...",
    required this.completionResult,
    this.delayMs = 10_000,
    this.tickProgressMs = 100,
    this.delayFeedback = "Starting in...",
    super.pomaCommands = const {},
  });

  @override
  Widget buildWidget(
    BuildContext context,
    void Function(T_Result result) onResult,
  ) {
    return ExperimentStageDelayWidget(
      key: ValueKey(id),
      stage: this,
      onComplete: onResult,
    );
  }

  factory ExperimentStageDelay.fromJson(
    Map<String, dynamic> json,
    T_Result Function(Object? json) fromJsonTResult,
  ) =>
      _$ExperimentStageDelayFromJson(json, fromJsonTResult);

  Map<String, dynamic> toJson(Object? Function(T_Result value) toJsonTResult) =>
      _$ExperimentStageDelayToJson(this, toJsonTResult);

  @override
  String getJsonType() {
    return jsonType;
  }
}
