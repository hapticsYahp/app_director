import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_app/core/experiment/experiment_stage_message.dart';

void main() {
  group('ExperimentStageMessage', () {
    final String id = 'message_id';
    final String exitedResult = 'EXITED';

    test('should have correct default values', () {
      final stage = ExperimentStageMessage<String>(
        id: id,
        exitedResult: exitedResult,
      );
      expect(stage.id, equals(id));
      expect(stage.exitedResult, equals(exitedResult));
      expect(stage.title, isNotNull);
      expect(stage.description, isNotNull);
      expect(stage.message, isNotNull);
      expect(stage.pomaCommands, isNotNull);
    });

    test('should allow custom values', () {
      final String title = 'Message Title';
      final String description = 'Message Description';
      final String message = 'Bye';
      final Map<String, String> pomaCommands = {
        'ENTER': 'enter_command',
        'EXIT': 'exit_command',
      };
      final stage = ExperimentStageMessage<String>(
        id: id,
        title: title,
        description: description,
        exitedResult: exitedResult,
        message: message,
        pomaCommands: pomaCommands,
      );
      expect(stage.title, equals(title));
      expect(stage.description, equals(description));
      expect(stage.message, equals(message));
      expect(stage.pomaCommands, equals(pomaCommands));
    });
  });
}
