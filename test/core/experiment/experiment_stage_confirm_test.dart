import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_app/core/experiment/experiment_stage_confirm.dart';

void main() {
  group('ExperimentStageConfirm', () {
    final String id = 'confirm_id';
    final String confirmationResult = 'CONFIRMED';

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
      final Map<String, String> pomaCommands = {
        'ENTER': 'enter_command',
        'EXIT': 'exit_command',
      };
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
  });
}
