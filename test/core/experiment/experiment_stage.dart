import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_app/core/experiment/experiment_stage.dart';

class MockExperimentStage extends ExperimentStage<String> {
  MockExperimentStage({
    required super.id,
    required super.title,
    required super.description,
    super.pomaCommands = const {},
  });

  @override
  Widget buildWidget(
      BuildContext context, void Function(String result) onResult) {
    return const SizedBox(); // Devuelve un widget mínimo para pruebas
  }
}

void main() {
  group('ExperimentStage', () {
    final String id = 'mock_id';
    final String title = 'Mock Stage';
    final String description = 'Mock Description';
    final Map<String, String> pomaCommands = {
      'ENTER': 'enter_command',
      'EXIT': 'exit_command',
    };
    late MockExperimentStage stage;

    setUp(() {
      stage = MockExperimentStage(
        id: id,
        title: title,
        description: description,
        pomaCommands: pomaCommands,
      );
    });

    test('should have correct initialization values', () {
      expect(stage.id, equals(id));
      expect(stage.title, equals(title));
      expect(stage.description, equals(description));
      expect(stage.pomaCommands, equals(pomaCommands));
    });
  });
}
