import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi_app/core/experiment/experiment_stage_wait.dart';
import 'package:wifi_app/providers/poma/poma_client.dart';
import 'experiment_stage_wait_test.mocks.dart';
import 'test_experiment.dart';

@GenerateMocks([TestExperiment, PomaClient])
void main() {
  group('ExperimentStageWait', () {
    final String id = 'wait_id';
    final String timeoutResult = 'TIMEOUT';
    final String feedbackResult = 'FEEDBACK';
    final String enterCommand = 'enter_command';
    final String exitCommand = 'exit_command';
    final String tickCommand1 = 'tick_command_1';
    final String tickCommand3 = 'tick_command_3';
    final String tickCommand5 = 'tick_command_5';
    final Map<String, String> pomaCommands = {
      'ENTER': enterCommand,
      'TICK_1000': tickCommand1,
      'TICK_3000': tickCommand3,
      'TICK_5000': tickCommand5,
      'EXIT': exitCommand,
    };

    late MockTestExperiment mockExperiment;
    late MockPomaClient mockPomaClient;
    late ExperimentStageWait<String> stage;

    setUp(() {
      mockExperiment = MockTestExperiment();
      mockPomaClient = MockPomaClient();
      when(mockExperiment.pomaClient).thenReturn(mockPomaClient);
      stage = ExperimentStageWait<String>(
        id: id,
        timeoutResult: timeoutResult,
        feedbackResult: feedbackResult,
        pomaCommands: pomaCommands,
      );
    });

    test('should have correct default values', () {
      final stage = ExperimentStageWait<String>(
        id: id,
        timeoutResult: timeoutResult,
        feedbackResult: feedbackResult,
      );
      expect(stage.id, equals(id));
      expect(stage.timeoutResult, equals(timeoutResult));
      expect(stage.feedbackResult, equals(feedbackResult));
      expect(stage.title, isNotNull);
      expect(stage.description, isNotNull);
      expect(stage.waitingMs, isNotNull);
      expect(stage.tickProgressMs, isNotNull);
      expect(stage.waitFeedback, isNotNull);
      expect(stage.buttonLabel, isNotNull);
      expect(stage.buttonIcon, isNotNull);
      expect(stage.pomaCommands, isNotNull);
    });

    test('should allow custom values', () {
      final String title = 'Wait Title';
      final String description = 'Wait Description';
      final int waitingMs = 5000;
      final int tickProgressMs = 500;
      final String waitFeedback = 'T:';
      final String buttonLabel = 'Button';
      final IconData buttonIcon = Icons.check;
      final stage = ExperimentStageWait<String>(
        id: id,
        title: title,
        description: description,
        timeoutResult: timeoutResult,
        feedbackResult: feedbackResult,
        waitingMs: waitingMs,
        tickProgressMs: tickProgressMs,
        waitFeedback: waitFeedback,
        buttonLabel: buttonLabel,
        buttonIcon: buttonIcon,
        pomaCommands: pomaCommands,
      );
      expect(stage.title, equals(title));
      expect(stage.description, equals(description));
      expect(stage.waitingMs, equals(waitingMs));
      expect(stage.tickProgressMs, equals(tickProgressMs));
      expect(stage.waitFeedback, equals(waitFeedback));
      expect(stage.buttonLabel, equals(buttonLabel));
      expect(stage.buttonIcon, equals(buttonIcon));
      expect(stage.pomaCommands, equals(pomaCommands));
    });

    test('should send ENTER command when stage is entered', () {
      stage.setExperiment(mockExperiment);
      when(mockPomaClient.isConnected()).thenReturn(true);
      stage.onEnter();
      verify(mockExperiment.sendPomaCommand(enterCommand)).called(1);
    });

    test('should send EXIT command when stage is exited', () {
      stage.setExperiment(mockExperiment);
      when(mockPomaClient.isConnected()).thenReturn(true);
      stage.onExit();
      verify(mockExperiment.sendPomaCommand(exitCommand)).called(1);
    });

    test('should send TICK commands on specific ticks', () {
      stage.setExperiment(mockExperiment);
      when(mockPomaClient.isConnected()).thenReturn(true);
      stage.onTick(1000);
      verify(mockExperiment.sendPomaCommand(tickCommand1)).called(1);
      stage.onTick(3000);
      verify(mockExperiment.sendPomaCommand(tickCommand3)).called(1);
      stage.onTick(7000);
      verifyNever(mockExperiment.sendPomaCommand(tickCommand5));
    });

    test('should not send commands when PomaClient is not connected', () {
      stage.setExperiment(mockExperiment);
      when(mockPomaClient.isConnected()).thenReturn(false);
      stage.onEnter();
      stage.onExit();
      stage.onTick(1000);
      verifyNever(mockPomaClient.send(any));
    });
  });
}
