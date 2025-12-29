import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:math';
import 'package:yahp_director/core/experiment/experiment_stage.dart';
import '../../components/experiment_stages/experiment_stage_shuffle_widget.dart';

part 'experiment_stage_shuffle.g.dart';

@JsonSerializable(genericArgumentFactories: true, explicitToJson: true)
class ExperimentStageShuffle<T_Result> extends ExperimentStage<T_Result> {
  static const String jsonType = 'shuffle';

  final List<String> stages;
  final List<String> visited = [];
  final T_Result completionResult;

  ExperimentStageShuffle({
    required super.id,
    super.title = "Shuffling",
    super.description = "Choosing next stage...",
    required this.stages,
    required this.completionResult,
    super.pomaCommands = const {},
  });

  bool hasNextStage() {
    return stages.length > visited.length;
  }

  String? getNextStageId() {
    String? nextStageId;
    if (hasNextStage()) {
      final remaining = stages
          .where((String id) => !visited.contains(id))
          .toList();
      if (remaining.isNotEmpty) {
        final randomIndex = Random().nextInt(remaining.length);
        nextStageId = remaining[randomIndex];
        visited.add(nextStageId);
      }
    }
    return nextStageId;
  }

  void reset() {
    visited.clear();
  }

  @override
  Widget buildWidget(
    BuildContext context,
    void Function(T_Result result) onResult,
  ) {
    return ExperimentStageShuffleWidget(
      key: ValueKey(id),
      stage: this,
      onComplete: onResult,
    );
  }

  factory ExperimentStageShuffle.fromJson(
    Map<String, dynamic> json,
    T_Result Function(Object? json) fromJsonTResult,
  ) => _$ExperimentStageShuffleFromJson(json, fromJsonTResult);

  @override
  Map<String, dynamic> toJson(Object? Function(T_Result value) toJsonTResult) =>
      _$ExperimentStageShuffleToJson(this, toJsonTResult);

  @override
  String getJsonType() => jsonType;
}
