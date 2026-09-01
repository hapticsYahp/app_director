import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:yahp_director/components/experiment_stages/experiment_stage_feedback_widget.dart';
import 'package:yahp_director/core/experiment/experiment_stage_feedback.dart';
import 'package:yahp_director/core/experiment/result_generator_to_string.dart';
import 'package:yahp_director/providers/poma/poma_client.dart';
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

    testWidgets('ExperimentStageFeedbackWidget negative button completes with minScaleValue', (
      WidgetTester tester,
    ) async {
      String? resultReceived;
      final feedbackStage = ExperimentStageFeedback<String>(
        id: 'fb_1',
        defaultResult: 'DEF',
        minScaleValue: 2,
        maxScaleValue: 8,
        resultGenerator: resultGenerator,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExperimentStageFeedbackWidget<String>(
              key: const ValueKey('fb_1'),
              stage: feedbackStage,
              onFeedback: (result) {
                resultReceived = result;
              },
            ),
          ),
        ),
      );

      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);

      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      expect(resultReceived, equals('2'));
    });

    testWidgets('ExperimentStageFeedbackWidget positive button opens scale and confirms selected value', (
      WidgetTester tester,
    ) async {
      String? resultReceived;
      final feedbackStage = ExperimentStageFeedback<String>(
        id: 'fb_2',
        defaultResult: 'DEF',
        minScaleValue: 1,
        maxScaleValue: 5,
        initialSelectedValue: 3,
        resultGenerator: resultGenerator,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExperimentStageFeedbackWidget<String>(
              key: const ValueKey('fb_2'),
              stage: feedbackStage,
              onFeedback: (result) {
                resultReceived = result;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('Indicate the perceived intensity: 3'), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(resultReceived, equals('3'));
    });

    testWidgets('ExperimentStageFeedbackWidget handles out of bounds initialSelectedValue gracefully without AssertionError', (
      WidgetTester tester,
    ) async {
      final feedbackStage = ExperimentStageFeedback<String>(
        id: 'fb_out_of_bounds',
        defaultResult: 'DEF',
        minScaleValue: 0,
        maxScaleValue: 10,
        initialSelectedValue: 999, // Out of bounds
        resultGenerator: resultGenerator,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExperimentStageFeedbackWidget<String>(
              key: const ValueKey('fb_out_of_bounds'),
              stage: feedbackStage,
              onFeedback: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('Indicate the perceived intensity: 10'), findsOneWidget);
    });

    testWidgets('ExperimentStageFeedbackWidget handles minScaleValue == maxScaleValue without AssertionError', (
      WidgetTester tester,
    ) async {
      String? resultReceived;
      final feedbackStage = ExperimentStageFeedback<String>(
        id: 'fb_zero_divisions',
        defaultResult: 'DEF',
        minScaleValue: 5,
        maxScaleValue: 5,
        initialSelectedValue: 5,
        resultGenerator: resultGenerator,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExperimentStageFeedbackWidget<String>(
              key: const ValueKey('fb_zero_divisions'),
              stage: feedbackStage,
              onFeedback: (result) {
                resultReceived = result;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('Indicate the perceived intensity: 5'), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(resultReceived, equals('5'));
    });

    testWidgets('ExperimentStageFeedbackWidget handles inverted min and max values gracefully without AssertionError', (
      WidgetTester tester,
    ) async {
      final feedbackStage = ExperimentStageFeedback<String>(
        id: 'fb_inverted',
        defaultResult: 'DEF',
        minScaleValue: 10,
        maxScaleValue: 0,
        initialSelectedValue: 5,
        resultGenerator: resultGenerator,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExperimentStageFeedbackWidget<String>(
              key: const ValueKey('fb_inverted'),
              stage: feedbackStage,
              onFeedback: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('Indicate the perceived intensity: 5'), findsOneWidget);
    });
  });
}
