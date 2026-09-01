import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:yahp_director/core/experiment/experiment.dart';
import 'package:yahp_director/core/experiment/experiment_stage.dart';
import 'package:yahp_director/core/graph/conditional_directed_graph.dart';
import 'package:yahp_director/core/graph/trigger_always.dart';
import 'package:yahp_director/core/trial/device_trial.dart';
import 'package:yahp_director/core/trial/experiment_trial.dart';
import 'package:yahp_director/core/trial/subject_trial.dart';
import 'package:yahp_director/providers/poma/poma_client.dart';

import 'experiment_test.mocks.dart';

@GenerateMocks([ExperimentStage, PomaClient])
void main() {
  group('Experiment', () {
    final String stageId1 = 'stage1';
    final String stageId2 = 'stage2';
    final String stageId3 = 'stage3';
    final String experimentId = 'exp_id';
    final String title = 'Test Experiment';
    final String description = 'This is a test experiment';

    late Map<String, ExperimentStage<String>> stages;
    late ConditionalDirectedGraph<String, String> transitions;
    late MockExperimentStage<String> mockStage1;
    late MockExperimentStage<String> mockStage2;
    late MockExperimentStage<String> mockStage3;
    late MockPomaClient mockPomaClient;
    late Experiment<String, String> experiment;

    setUp(() {
      mockStage1 = MockExperimentStage<String>();
      mockStage2 = MockExperimentStage<String>();
      mockStage3 = MockExperimentStage<String>();
      when(mockStage1.id).thenReturn(stageId1);
      when(mockStage2.id).thenReturn(stageId2);
      when(mockStage3.id).thenReturn(stageId3);
      stages = {
        stageId1: mockStage1,
        stageId2: mockStage2,
        stageId3: mockStage3,
      };
      transitions = ConditionalDirectedGraph<String, String>();
      transitions.addRule(stageId1, TriggerAlways<String>(), stageId2);
      transitions.addRule(stageId2, TriggerAlways<String>(), stageId3);
      mockPomaClient = MockPomaClient();
      experiment = Experiment<String, String>(
        id: experimentId,
        title: title,
        description: description,
        stages: stages,
        transitions: transitions,
      );
    });

    test('should init with required parameters', () {
      expect(experiment.id, equals(experimentId));
      expect(experiment.title, equals(title));
      expect(experiment.description, equals(description));
      expect(experiment.currentStage, equals(mockStage1));
      expect(experiment.canAdvance, isTrue);
      verify(mockStage1.setExperiment(experiment)).called(1);
      verify(mockStage2.setExperiment(experiment)).called(1);
      verify(mockStage3.setExperiment(experiment)).called(1);
    });

    test('should init with custom initial, last and cancel stage IDs', () {
      final experiment = Experiment<String, String>(
        id: experimentId,
        title: title,
        description: description,
        stages: stages,
        transitions: transitions,
        initialStageId: stageId2,
        lastStageId: stageId3,
        cancelStageId: stageId1,
      );
      expect(experiment.currentStage, equals(mockStage2));
    });

    test('should throw exception when initializing with empty stages', () {
      expect(
        () => Experiment<String, String>(
          id: experimentId,
          title: title,
          description: description,
          stages: {},
          transitions: transitions,
        ),
        throwsException,
      );
    });

    test(
      'advanceToStage should change current stage and trigger lifecycle callbacks',
      () {
        expect(experiment.currentStage, equals(mockStage1));
        experiment.advanceToStage(stageId2);
        verify(mockStage1.onExit()).called(1);
        verify(mockStage2.onEnter()).called(1);
        expect(experiment.currentStage, equals(mockStage2));
      },
    );

    test(
      'advanceToStage should support self-loops (advancing to the same stage)',
      () {
        expect(experiment.currentStage, equals(mockStage1));
        bool notified = false;
        experiment.addListener(() {
          notified = true;
        });

        experiment.advanceToStage(stageId1);
        verify(mockStage1.onExit()).called(1);
        verify(mockStage1.onEnter()).called(1);
        expect(experiment.currentStage, equals(mockStage1));
        expect(notified, isTrue);
      },
    );

    test('advanceToStage should throw exception for invalid stage ID', () {
      expect(() => experiment.advanceToStage('invalid_stage'), throwsException);
    });

    test(
      'advanceByResult should follow transition rules and trigger lifecycle callbacks',
      () async {
        expect(experiment.currentStage, equals(mockStage1));
        await experiment.advanceByResult('any_result');
        verify(mockStage1.onExit()).called(1);
        verify(mockStage2.onEnter()).called(1);
        expect(experiment.currentStage, equals(mockStage2));
      },
    );

    test(
      'advanceByResult should support self-loop transition back to the same stage',
      () async {
        final loopTransitions = ConditionalDirectedGraph<String, String>();
        loopTransitions.addRule(stageId1, TriggerAlways<String>(), stageId1);
        final loopExperiment = Experiment<String, String>(
          id: experimentId,
          title: title,
          description: description,
          stages: stages,
          transitions: loopTransitions,
        );
        expect(loopExperiment.currentStage, equals(mockStage1));
        await loopExperiment.advanceByResult('loop_result');
        verify(mockStage1.onExit()).called(1);
        verify(mockStage1.onEnter()).called(1);
        expect(loopExperiment.currentStage, equals(mockStage1));
      },
    );

    test('start should trigger onEnter on starting stage', () async {
      final trial = ExperimentTrial(
        'trial_1',
        experiment,
        SubjectTrial(id: 'subj_1', name: 'Subject 1'),
        DeviceTrial(id: 'dev_1', name: 'Device 1'),
      );
      await experiment.start(trial);
      verify(mockStage1.onEnter()).called(1);
      expect(experiment.trial, equals(trial));
    });

    test('end should call onExit on current stage and return trial', () async {
      final trial = ExperimentTrial(
        'trial_1',
        experiment,
        SubjectTrial(id: 'subj_1', name: 'Subject 1'),
        DeviceTrial(id: 'dev_1', name: 'Device 1'),
      );
      await experiment.start(trial);
      final endedTrial = experiment.end();
      verify(mockStage1.onExit()).called(1);
      expect(endedTrial, equals(trial));
    });

    test(
      'reset should call onExit and return to initial stage triggering onEnter',
      () {
        experiment.advanceToStage(stageId2);
        expect(experiment.currentStage, equals(mockStage2));
        experiment.reset();
        verify(mockStage2.onExit()).called(1);
        verify(mockStage1.onEnter()).called(1);
        expect(experiment.currentStage, equals(mockStage1));
      },
    );

    test(
      'reset when already at initial stage should call onExit and onEnter on initial stage',
      () {
        expect(experiment.currentStage, equals(mockStage1));
        experiment.reset();
        verify(mockStage1.onExit()).called(1);
        verify(mockStage1.onEnter()).called(1);
        expect(experiment.currentStage, equals(mockStage1));
      },
    );

    test(
      'finish should call onExit on current stage and go to end stage with onEnter',
      () {
        experiment.finish();
        verify(mockStage1.onExit()).called(1);
        verify(mockStage3.onEnter()).called(1);
        expect(experiment.currentStage, equals(mockStage3));
      },
    );

    test(
      'abort should call onExit on current stage and go to abort stage with onEnter',
      () {
        experiment.abort();
        verify(mockStage1.onExit()).called(1);
        verify(mockStage3.onEnter()).called(1);
        expect(experiment.currentStage, equals(mockStage3));
      },
    );

    test('canAdvance should return true when transitions exist', () {
      expect(experiment.canAdvance, isTrue);
    });

    test('canAdvance should return false when no transitions exist', () {
      experiment.advanceToStage(stageId3);
      expect(experiment.canAdvance, isFalse);
    });

    test('setPomaClient should properly set the client', () {
      experiment.setPomaClient(mockPomaClient);
      expect(experiment.pomaClient, equals(mockPomaClient));
    });

    test('should send PoMA command when PoMA client is connected', () {
      final String command = 'test_command';
      experiment.setPomaClient(mockPomaClient);
      when(mockPomaClient.isConnected()).thenReturn(true);
      experiment.sendPomaCommand(command);
      verify(mockPomaClient.send(command)).called(1);
    });

    test('should not send PoMA command when PoMA client is not connected', () {
      experiment.setPomaClient(mockPomaClient);
      when(mockPomaClient.isConnected()).thenReturn(false);
      experiment.sendPomaCommand('test_command');
      verifyNever(mockPomaClient.send(any));
    });

    test('should not fail when sending PoMA command and client is null', () {
      expect(() => experiment.sendPomaCommand('test_command'), returnsNormally);
    });
  });
}
