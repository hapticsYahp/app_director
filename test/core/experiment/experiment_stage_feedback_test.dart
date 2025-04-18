import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi_app/core/experiment/experiment_stage_feedback.dart';
import 'package:wifi_app/core/experiment/result_generator_to_string.dart';
import 'package:wifi_app/providers/poma/poma_client.dart';
import 'experiment_stage_feedback_test.mocks.dart';
import 'test_experiment.dart';

@GenerateMocks([TestExperiment, PomaClient])
void main() {
  group('ExperimentStageFeedback', () {
    final String id = 'feedback_id';
    final String enterCommand = 'enter_command';
    final String exitCommand = 'exit_command';
    final Map<String, String> pomaCommands = {
      'ENTER': enterCommand,
      'EXIT': exitCommand,
    };
    final String defaultResult = "NO_RESULT";

    late MockTestExperiment mockExperiment;
    late MockPomaClient mockPomaClient;
    late ExperimentStageFeedback<String> stage;
    late ResultGeneratorToString resultGenerator;

    setUp(() {
      mockExperiment = MockTestExperiment();
      mockPomaClient = MockPomaClient();
      when(mockExperiment.pomaClient).thenReturn(mockPomaClient);
      resultGenerator = ResultGeneratorToString();
      stage = ExperimentStageFeedback<String>(
        id: id,
        defaultResult: defaultResult,
        pomaCommands: pomaCommands,
      );
    });

    test('should have correct default values', () {
      final stage = ExperimentStageFeedback<String>(
        id: id,
        defaultResult: defaultResult,
      );
      expect(stage.id, equals(id));
      expect(stage.defaultResult, equals(defaultResult));
      expect(stage.title, isNotNull);
      expect(stage.description, isNotNull);
      expect(stage.minScaleValue, isNotNull);
      expect(stage.maxScaleValue, isNotNull);
      expect(stage.initialSelectedValue, isNotNull);
      expect(stage.positiveLabel, isNotNull);
      expect(stage.negativeLabel, isNotNull);
      expect(stage.feedbackLabel, isNotNull);
      expect(stage.confirmLabel, isNotNull);
      expect(stage.positiveIcon, isNotNull);
      expect(stage.negativeIcon, isNotNull);
      expect(stage.confirmIcon, isNotNull);
      expect(stage.pomaCommands, isNotNull);
    });

    test('should allow custom values', () {
      final String title = 'Feedback Title';
      final String description = 'Feedback Description';
      final int minScaleValue = 1;
      final int maxScaleValue = 5;
      final int initialSelectedValue = 3;
      final String positiveLabel = "Positive";
      final String negativeLabel = "Negative";
      final String feedbackLabel = "Feedback";
      final String confirmLabel = "Submit";
      final IconData positiveIcon = Icons.add;
      final IconData negativeIcon = Icons.remove;
      final IconData confirmIcon = Icons.send;
      final stage = ExperimentStageFeedback<String>(
        id: id,
        title: title,
        description: description,
        minScaleValue: minScaleValue,
        maxScaleValue: maxScaleValue,
        initialSelectedValue: initialSelectedValue,
        positiveLabel: positiveLabel,
        negativeLabel: negativeLabel,
        feedbackLabel: feedbackLabel,
        confirmLabel: confirmLabel,
        resultGenerator: resultGenerator,
        defaultResult: defaultResult,
        positiveIcon: positiveIcon,
        negativeIcon: negativeIcon,
        confirmIcon: confirmIcon,
        pomaCommands: pomaCommands,
      );
      expect(stage.title, equals(title));
      expect(stage.description, equals(description));
      expect(stage.minScaleValue, equals(minScaleValue));
      expect(stage.maxScaleValue, equals(maxScaleValue));
      expect(stage.initialSelectedValue, equals(initialSelectedValue));
      expect(stage.positiveLabel, equals(positiveLabel));
      expect(stage.negativeLabel, equals(negativeLabel));
      expect(stage.feedbackLabel, equals(feedbackLabel));
      expect(stage.confirmLabel, equals(confirmLabel));
      expect(stage.resultGenerator, equals(resultGenerator));
      expect(stage.positiveIcon, equals(positiveIcon));
      expect(stage.negativeIcon, equals(negativeIcon));
      expect(stage.confirmIcon, equals(confirmIcon));
      expect(stage.pomaCommands, equals(pomaCommands));
    });

    test('should properly transform scale values with ResultGenerator', () {
      final stage = ExperimentStageFeedback<String>(
        id: id,
        resultGenerator: resultGenerator,
        defaultResult: defaultResult,
      );
      expect(stage.getResult(0), equals(resultGenerator.getResult(0)));
      expect(stage.getResult(5), equals(resultGenerator.getResult(5)));
      expect(stage.getResult(10), equals(resultGenerator.getResult(10)));
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

    test('should not send commands when PomaClient is not connected', () {
      stage.setExperiment(mockExperiment);
      when(mockPomaClient.isConnected()).thenReturn(false);
      stage.onEnter();
      stage.onExit();
      verifyNever(mockPomaClient.send(any));
    });
  });
}
