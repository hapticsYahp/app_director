import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yahp_director/core/experiment/experiment_stage.dart';
import '../../providers/poma/poma_client.dart';
import '../graph/conditional_directed_graph.dart';
import '../trial/experiment_trial.dart';

class Experiment<T_Stage_Id, T_Stage_Result> {
  final String id;
  final String title;
  final String description;

  @JsonKey(includeFromJson: false, includeToJson: false)
  PomaClient? pomaClient;

  @JsonKey(includeToJson: false, includeFromJson: false)
  ExperimentTrial? trial;

  final Map<T_Stage_Id, ExperimentStage<T_Stage_Result>> stages;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final ConditionalDirectedGraph<T_Stage_Id, T_Stage_Result> transitions;

  late final T_Stage_Id startingStageId;
  late final T_Stage_Id finalStageId;
  late final T_Stage_Id abortStageId;

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
    startingStageId = initialStageId ?? stages.keys.first;
    finalStageId = lastStageId ?? stages.keys.last;
    abortStageId = cancelStageId ?? finalStageId;
    _currentStageId = startingStageId;
  }

  void saveTrialEvent(String name,
      {Map<String, dynamic> extraData = const {}}) {
    this.trial?.saveTrialEvent(name, extraData: extraData);
  }

  void setPomaClient(PomaClient pomaClient) {
    this.pomaClient = pomaClient;
  }

  void sendPomaCommand(String pomaCommand) {
    this.saveTrialEvent("POMA_COMMAND", extraData: {
      'command': pomaCommand,
      'stageId': _currentStageId,
    });
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
    if (_currentStageId != stageId) {
      this.saveTrialEvent("EXPERIMENT_ADVANCE", extraData: {
        'toStageId': stageId.toString(),
        'fromStageId': _currentStageId,
      });
      _currentStageId = stageId;
    }
  }

  Future<void> advanceByResult(T_Stage_Result result) async {
    this.saveTrialEvent("STAGE_RESULT", extraData: {
      'result': result.toString(),
      'stageId': _currentStageId,
    });
    advanceToStage(
        transitions.getDestination(_currentStageId, result) ?? abortStageId);
  }

  bool get canAdvance {
    return transitions.getDestinationsFromOrigin(_currentStageId).isNotEmpty;
  }

  Future<void> start(ExperimentTrial trial) async {
    this.trial = trial;
    this.saveTrialEvent("EXPERIMENT_START");
    advanceToStage(startingStageId);
  }

  ExperimentTrial? end() {
    this.saveTrialEvent("EXPERIMENT_END");
    currentStage.onExit();
    return trial;
  }

  void reset() {
    this.saveTrialEvent("EXPERIMENT_RESET");
    currentStage.onExit();
    advanceToStage(startingStageId);
  }

  void finish() {
    this.saveTrialEvent("EXPERIMENT_FINISH");
    currentStage.onExit();
    advanceToStage(finalStageId);
  }

  void abort() {
    this.saveTrialEvent("EXPERIMENT_ABORT");
    currentStage.onExit();
    advanceToStage(abortStageId);
  }
}
