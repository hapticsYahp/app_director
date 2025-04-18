import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_app/core/experiment/experiment_stage_feedback.dart';

void main() {
  group('ExperimentStageFeedback', () {
    final String id = 'feedback_id';
    getResult(value) => 'FEEDBACK_$value';

    test('should have correct default values', () {
      final stage = ExperimentStageFeedback<String>(
        id: id,
        getResult: getResult,
      );
      expect(stage.id, equals(id));
      expect(stage.getResult, equals(getResult));
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
      final Map<String, String> pomaCommands = {
        'ENTER': 'enter_command',
        'EXIT': 'exit_command',
      };
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
        getResult: getResult,
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
      expect(stage.positiveIcon, equals(positiveIcon));
      expect(stage.negativeIcon, equals(negativeIcon));
      expect(stage.confirmIcon, equals(confirmIcon));
      expect(stage.pomaCommands, equals(pomaCommands));
    });

    test('should properly transform scale values with getResult function', () {
      final stage = ExperimentStageFeedback<String>(
        id: id,
        getResult: getResult,
      );
      expect(stage.getResult(0), equals(getResult(0)));
      expect(stage.getResult(5), equals(getResult(5)));
      expect(stage.getResult(10), equals(getResult(10)));
    });
  });
}
