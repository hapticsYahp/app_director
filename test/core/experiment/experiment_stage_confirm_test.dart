import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi_app/core/experiment/experiment_stage_confirm.dart';
import 'package:wifi_app/providers/poma/poma_client.dart';
import 'experiment_stage_confirm_test.mocks.dart';
import 'test_experiment.dart';

@GenerateMocks([TestExperiment, PomaClient])
void main() {
  group('ExperimentStageConfirm', () {
    final String id = 'confirm_id';
    final String confirmationResult = 'CONFIRMED';
    final String enterCommand = 'enter_command';
    final String exitCommand = 'exit_command';
    final Map<String, String> pomaCommands = {
      'ENTER': enterCommand,
      'EXIT': exitCommand,
    };

    late MockTestExperiment mockExperiment;
    late MockPomaClient mockPomaClient;
    late ExperimentStageConfirm<String> stage;

    setUp(() {
      mockExperiment = MockTestExperiment();
      mockPomaClient = MockPomaClient();
      when(mockExperiment.pomaClient).thenReturn(mockPomaClient);
      stage = ExperimentStageConfirm<String>(
        id: id,
        confirmationResult: confirmationResult,
        pomaCommands: pomaCommands,
      );
    });

    test('should have default values', () {
      final stage = ExperimentStageConfirm<String>(
        id: id,
        confirmationResult: confirmationResult,
      );
      expect(stage.id, equals(id));
      expect(stage.confirmationResult, equals(confirmationResult));
      expect(stage.title, isNotNull);
      expect(stage.description, isNotNull);
      expect(stage.buttonLabel, isNotNull);
      expect(stage.buttonIcon, isNotNull);
      expect(stage.pomaCommands, isNotNull);
    });

    test('should allow custom values', () {
      final String title = 'Confirm Title';
      final String description = 'Confirm Description';
      final String buttonLabel = "Confirm Label";
      final IconData buttonIcon = Icons.confirmation_num;
      final stage = ExperimentStageConfirm<String>(
        id: id,
        title: title,
        description: description,
        confirmationResult: confirmationResult,
        buttonLabel: buttonLabel,
        buttonIcon: buttonIcon,
        pomaCommands: pomaCommands,
      );
      expect(stage.title, equals(title));
      expect(stage.description, equals(description));
      expect(stage.buttonLabel, equals(buttonLabel));
      expect(stage.buttonIcon, equals(buttonIcon));
      expect(stage.pomaCommands, equals(pomaCommands));
    });

    test('should send ENTER command when stage is entered', () {
      final String enterCommand = 'enter_command';
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

    test('should not send commands when PomaClient is not connected', () {
      stage.setExperiment(mockExperiment);
      when(mockPomaClient.isConnected()).thenReturn(false);
      stage.onEnter();
      stage.onExit();
      verifyNever(mockPomaClient.send(any));
    });

    test('should handle null PomaClient gracefully', () {
      when(mockExperiment.pomaClient).thenReturn(null);
      stage.setExperiment(mockExperiment);
      expect(() => stage.onEnter(), returnsNormally);
      expect(() => stage.onExit(), returnsNormally);
    });
  });
}
