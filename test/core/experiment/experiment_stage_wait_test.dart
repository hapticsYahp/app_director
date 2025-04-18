import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_app/core/experiment/experiment_stage_wait.dart';

void main() {
  group('ExperimentStageWait', () {
    final String id = 'wait_id';
    final String timeoutResult = 'TIMEOUT';
    final String feedbackResult = 'FEEDBACK';

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
    });

    test('should allow custom values', () {
      final String title = 'Wait Title';
      final String description = 'Wait Description';
      final int waitingMs = 5000;
      final int tickProgressMs = 500;
      final String waitFeedback = 'T:';
      final String buttonLabel = 'Button';
      final IconData buttonIcon = Icons.check;
      final Map<String, String> pomaCommands = {
        'ENTER': 'enter_command',
        'EXIT': 'exit_command',
      };
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
  });
}
