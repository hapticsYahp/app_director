import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_app/core/experiment/experiment_stage.dart';
import 'package:wifi_app/core/experiment/experiment_stage_confirm.dart';
import 'package:wifi_app/core/experiment/experiment_stage_message.dart';
import 'package:wifi_app/core/graph/trigger_always.dart';
import 'package:wifi_app/core/graph/trigger_equals.dart';
import 'package:wifi_app/core/serialization/serializable_conditional_directed_graph.dart';
import 'package:wifi_app/core/serialization/serializable_experiment.dart';

void main() {
  group('SerializableExperiment', () {
    final String experimentId = 'exp_id';
    final String title = 'Simple Test Experiment';
    final String description = 'Simple Test Experiment Description';
    final String stageStartId = 'start';
    final String stageEndId = 'end';
    final String continueResult = "CONTINUE";
    final String exitedResult = "EXIT";
    final String startLabel = "Start!";
    final String message = "Bye!";

    late SerializableExperiment simpleExperiment;

    setUp(() {
      final transitions = SerializableConditionalDirectedGraph();
      transitions.addRule(
          stageStartId, TriggerEquals(continueResult), stageEndId);
      transitions.addRule(stageEndId, TriggerAlways(), stageStartId);
      final stages = <String, ExperimentStage<String>>{
        stageStartId: ExperimentStageConfirm<String>(
          id: stageStartId,
          title: 'Start',
          description: 'Start Description',
          confirmationResult: continueResult,
          buttonLabel: startLabel,
          buttonIcon: Icons.play_arrow,
        ),
        stageEndId: ExperimentStageMessage<String>(
          id: stageEndId,
          title: 'End',
          description: 'Experiment ended',
          exitedResult: exitedResult,
          message: message,
        ),
      };
      simpleExperiment = SerializableExperiment(
        id: experimentId,
        title: title,
        description: description,
        stages: stages,
        serializableTransitions: transitions,
        initialStageId: stageStartId,
        lastStageId: stageEndId,
      );
    });

    test('should correctly serialize to JSON', () {
      final json = simpleExperiment.toJson();
      expect(json['id'], equals(experimentId));
      expect(json['title'], equals(title));
      expect(json['description'], equals(description));

      expect(json['stages'], isA<Map<String, dynamic>>());
      expect(json['stages'], hasLength(2));
      expect(json['stages'].keys, contains(stageStartId));
      expect(json['stages'].keys, contains(stageEndId));

      expect(json['transitions'], isA<Map<String, dynamic>>());
      expect(json['transitions']['rules'], isA<List>());
      expect(json['transitions']['rules'], hasLength(2));

      expect(json['startingStageId'], equals(stageStartId));
      expect(json['finalStageId'], equals(stageEndId));
      expect(json['abortStageId'], equals(stageEndId));
    });

    test('should correctly deserialize from JSON', () {
      final json = simpleExperiment.toJson();
      final restored = SerializableExperiment.fromJson(json);
      expect(restored.id, equals(experimentId));
      expect(restored.title, equals(title));
      expect(restored.description, equals(description));

      expect(restored.stages.keys, contains(stageStartId));
      expect(restored.stages.keys, contains(stageEndId));
      expect(restored.stages.keys, hasLength(2));
      expect(
          restored.stages[stageStartId], isA<ExperimentStageConfirm<String>>());
      expect(
          restored.stages[stageEndId], isA<ExperimentStageMessage<String>>());

      expect(restored.transitions, isA<SerializableConditionalDirectedGraph>());
      expect(restored.transitions.rules, hasLength(2));

      expect(restored.startingStageId, equals(stageStartId));
      expect(restored.finalStageId, equals(stageEndId));
      expect(restored.abortStageId, equals(stageEndId));

      expect(restored.currentStage.id, equals(stageStartId));

      final startStage =
          restored.stages[stageStartId] as ExperimentStageConfirm<String>;
      expect(startStage.confirmationResult, equals(continueResult));
      expect(startStage.buttonLabel, equals(startLabel));

      final endStage =
          restored.stages[stageEndId] as ExperimentStageMessage<String>;
      expect(endStage.exitedResult, equals(exitedResult));
      expect(endStage.message, equals(message));
    });

    test('should maintain consistency through multiple serializations', () {
      final json1 = simpleExperiment.toJson();
      final restored = SerializableExperiment.fromJson(json1);
      final json2 = restored.toJson();
      expect(json2['id'], equals(json1['id']));
      expect(json2['title'], equals(json1['title']));
      expect(json2['description'], equals(json1['description']));
      expect(simpleExperiment.id, equals(restored.id));
      expect(simpleExperiment.title, equals(restored.title));
      expect(simpleExperiment.description, equals(restored.description));

      expect(json2['startingStageId'], equals(json1['startingStageId']));
      expect(json2['finalStageId'], equals(json1['finalStageId']));
      expect(json2['abortStageId'], equals(json1['abortStageId']));
      expect(
          simpleExperiment.startingStageId, equals(restored.startingStageId));
      expect(simpleExperiment.finalStageId, equals(restored.finalStageId));
      expect(simpleExperiment.abortStageId, equals(restored.abortStageId));

      expect(restored.stages.keys, equals(simpleExperiment.stages.keys));
      expect(restored.transitions.rules.length,
          equals(simpleExperiment.transitions.rules.length));

      restored.advanceToStage(stageStartId);
      expect(restored.currentStage.id, equals(stageStartId));

      restored.advanceByResult(continueResult);
      expect(restored.currentStage.id, equals(stageEndId));
    });
  });
}
