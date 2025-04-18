import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_app/core/experiment/experiment_stage_delay.dart';

void main() {
  group('ExperimentStageDelay', () {
    final String id = 'delay_id';
    final String completionResult = 'COMPLETED';

    test('should have correct default values', () {
      final stage = ExperimentStageDelay<String>(
        id: id,
        completionResult: completionResult,
      );
      expect(stage.id, equals(id));
      expect(stage.completionResult, equals(completionResult));
      expect(stage.title, isNotNull);
      expect(stage.description, isNotNull);
      expect(stage.delayMs, isNotNull);
      expect(stage.tickProgressMs, isNotNull);
      expect(stage.delayFeedback, isNotNull);
      expect(stage.pomaCommands, isNotNull);
    });

    test('should allow custom values', () {
      final String title = 'Delay Title';
      final String description = 'Delay Description';
      final int delayMs = 5000;
      final int tickProgressMs = 200;
      final String delayFeedback = "Delay feedback";
      final Map<String, String> pomaCommands = {
        'ENTER': 'enter_command',
        'EXIT': 'exit_command',
      };
      final stage = ExperimentStageDelay<String>(
        id: id,
        title: title,
        description: description,
        completionResult: completionResult,
        delayMs: delayMs,
        tickProgressMs: tickProgressMs,
        delayFeedback: delayFeedback,
        pomaCommands: pomaCommands,
      );

      expect(stage.title, equals(title));
      expect(stage.description, equals(description));
      expect(stage.delayMs, equals(delayMs));
      expect(stage.tickProgressMs, equals(tickProgressMs));
      expect(stage.delayFeedback, equals(delayFeedback));
      expect(stage.pomaCommands, equals(pomaCommands));
    });
  });
}
