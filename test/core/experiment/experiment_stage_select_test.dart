import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi_app/core/experiment/experiment_stage_select.dart';
import 'package:wifi_app/providers/poma/poma_client.dart';
import 'experiment_stage_select_test.mocks.dart';
import 'test_experiment.dart';

@GenerateMocks([TestExperiment, PomaClient])
void main() {
  group('ExperimentStageSelect', () {
    const String id = 'select_id';
    const String enterCommand = 'enter_command';
    const String exitCommand = 'exit_command';
    final Map<String, String> pomaCommands = {
      'ENTER': enterCommand,
      'EXIT': exitCommand,
    };

    late MockTestExperiment mockExperiment;
    late MockPomaClient mockPomaClient;

    setUp(() {
      mockExperiment = MockTestExperiment();
      mockPomaClient = MockPomaClient();
      when(mockExperiment.pomaClient).thenReturn(mockPomaClient);
    });

    test('should have default values', () {
      final stage = ExperimentStageSelect<String>(
        id: id,
        options: [
          SelectOption(label: 'A', value: 'A'),
          SelectOption(label: 'B', value: 'B'),
        ],
      );
      expect(stage.id, equals(id));
      expect(stage.title, isNotNull);
      expect(stage.description, isNotNull);
      expect(stage.question, isNotEmpty);
      expect(stage.multipleSelection, isFalse);
      expect(stage.shuffleOptions, isFalse);
      expect(stage.options.length, 2);
      expect(stage.confirmButtonLabel, isNotEmpty);
      expect(stage.clearButtonLabel, isNotEmpty);
    });

    test('should allow custom values and serialize/deserialize', () {
      final stage = ExperimentStageSelect<String>(
        id: id,
        title: 'Select Title',
        description: 'Select Description',
        question: 'Pick one',
        multipleSelection: true,
        shuffleOptions: true,
        options: [
          SelectOption(label: 'One', value: '1'),
          SelectOption(label: 'Two', value: '2'),
        ],
        confirmButtonLabel: 'OK',
        confirmButtonIcon: Icons.done,
        clearButtonLabel: 'Clear',
        clearButtonIcon: Icons.delete,
        pomaCommands: pomaCommands,
      );

      final json = stage.toJson((value) => value);
      expect(json['id'], id);
      expect(json['multipleSelection'], true);
      expect(json['shuffleOptions'], true);
      expect((json['options'] as List).length, 2);
      expect(json['confirmButtonLabel'], 'OK');
      expect(json['clearButtonLabel'], 'Clear');

      final restored = ExperimentStageSelect.fromJson(json, (o) => o as String);
      expect(restored.title, equals('Select Title'));
      expect(restored.description, equals('Select Description'));
      expect(restored.question, equals('Pick one'));
      expect(restored.multipleSelection, isTrue);
      expect(restored.shuffleOptions, isTrue);
      expect(restored.options[0].label, equals('One'));
      expect(restored.options[0].value, equals('1'));
      expect(restored.confirmButtonLabel, equals('OK'));
      expect(restored.clearButtonLabel, equals('Clear'));
      expect(restored.pomaCommands, equals(pomaCommands));
    });

    test('should send ENTER/EXIT commands with PoMA', () {
      final stage = ExperimentStageSelect<String>(
        id: id,
        options: [SelectOption(label: 'A', value: 'A')],
        pomaCommands: pomaCommands,
      );
      stage.setExperiment(mockExperiment);
      when(mockPomaClient.isConnected()).thenReturn(true);
      stage.onEnter();
      verify(mockExperiment.sendPomaCommand(enterCommand)).called(1);
      stage.onExit();
      verify(mockExperiment.sendPomaCommand(exitCommand)).called(1);
    });
  });
}
