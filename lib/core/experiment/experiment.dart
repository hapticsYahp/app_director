import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wifi_app/core/experiment/experiment_stage.dart';
import '../../providers/poma/poma_client.dart';
import '../graph/conditional_directed_graph.dart';

class Experiment<T_Stage_Id, T_Stage_Result> {
  final String id;
  final String title;
  final String description;

  @JsonKey(includeFromJson: false, includeToJson: false)
  PomaClient? pomaClient;

  final Map<T_Stage_Id, ExperimentStage<T_Stage_Result>> stages;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final ConditionalDirectedGraph<T_Stage_Id, T_Stage_Result> transitions;
  late T_Stage_Id _initialStageId;
  late T_Stage_Id _endStageId;
  late T_Stage_Id _abortStageId;

  late T_Stage_Id _currentStageId;

  ExperimentStage<T_Stage_Result> get currentStage => stages[_currentStageId]!;

  Experiment({
    required this.id,
    required this.title,
    required this.description,
    required this.stages,
    required this.transitions,
    T_Stage_Id? initialStageId,
    T_Stage_Id? lastStageId,
    T_Stage_Id? cancelStageId,
  }) {
    if (stages.keys.isEmpty) {
      throw Exception('Experiment without Stages.');
    }
    for (ExperimentStage<T_Stage_Result> stage in stages.values) {
      stage.setExperiment(this);
    }
    _initialStageId = initialStageId ?? stages.keys.first;
    _endStageId = lastStageId ?? stages.keys.last;
    _abortStageId = cancelStageId ?? _endStageId;
    _currentStageId = _initialStageId;
  }

  void setPomaClient(PomaClient pomaClient) {
    this.pomaClient = pomaClient;
  }

  void sendPomaCommand(String pomaCommand) {
    if (pomaClient?.isConnected() == true) {
      pomaClient!.send(pomaCommand);
    } else {
      debugPrint("Cannot send PoMA command: '$pomaCommand'."); // TODO: quitar.
    }
  }

  void advanceToStage(T_Stage_Id stageId) {
    if (!stages.containsKey(stageId)) {
      throw Exception('Invalid Stage ID "$stageId".');
    }
    _currentStageId = stageId;
  }

  Future<void> advanceByResult(T_Stage_Result result) async {
    advanceToStage(
        transitions.getDestination(_currentStageId, result) ?? _abortStageId);
  }

  bool get canAdvance {
    return transitions.getDestinationsFromOrigin(_currentStageId).isNotEmpty;
  }

  void reset() {
    currentStage.onExit();
    advanceToStage(_initialStageId);
  }

  void finish() {
    currentStage.onExit();
    advanceToStage(_endStageId);
  }

  void abort() {
    currentStage.onExit();
    advanceToStage(_abortStageId);
  }
}
