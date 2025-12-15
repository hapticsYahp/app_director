import 'dart:math';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yahp_director/core/experiment/experiment_stage.dart';
import '../../components/experiment_stages/experiment_stage_delay_widget.dart';

part 'experiment_stage_delay.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ExperimentStageDelay<T_Result> extends ExperimentStage<T_Result> {
  static const String jsonType = 'delay';

  final T_Result completionResult;
  final int minDelayMs;
  final int maxDelayMs;
  final int tickProgressMs;
  final String delayFeedback;
  final bool showProgressBar;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late int delayMs;

  ExperimentStageDelay({
    required super.id,
    super.title = "Delay",
    super.description = "Delaying...",
    required this.completionResult,
    this.minDelayMs = 5_000,
    this.maxDelayMs = 10_000,
    this.tickProgressMs = 100,
    this.delayFeedback = "Starting in...",
    this.showProgressBar = true,
    super.pomaCommands = const {},
  });

  void _randomizeDelay() {
    final random = Random();
    this.delayMs =
        this.minDelayMs + random.nextInt(this.maxDelayMs - this.minDelayMs);
    experiment?.saveTrialEvent("TRIAL_ENV", extraData: {
      'delayMs': this.delayMs,
    });
  }

  @override
  void onEnter() {
    super.onEnter();
    _randomizeDelay();
  }

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

  @override
  Map<String, dynamic> toJson(Object? Function(T_Result value) toJsonTResult) =>
      _$ExperimentStageDelayToJson(this, toJsonTResult);

  @override
  String getJsonType() {
    return jsonType;
  }
}
