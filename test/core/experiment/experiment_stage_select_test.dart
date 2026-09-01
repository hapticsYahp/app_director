import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:yahp_director/components/experiment_stages/experiment_stage_select_widget.dart';
import 'package:yahp_director/core/experiment/experiment_stage_select.dart';
import 'package:yahp_director/providers/poma/poma_client.dart';
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

    test('getResult should return String when T_Result is String', () {
      final stage = ExperimentStageSelect<String>(
        id: id,
        options: [SelectOption(label: 'Option 1', value: 'opt_1')],
      );
      expect(stage.getResult('opt_1'), equals('opt_1'));
    });

    test('getResult should use resultConverter when provided for custom types', () {
      final stage = ExperimentStageSelect<int>(
        id: id,
        options: [
          SelectOption(label: 'One', value: '1'),
          SelectOption(label: 'Two', value: '2'),
        ],
        resultConverter: (value) => int.parse(value),
      );
      expect(stage.getResult('2'), equals(2));
    });

    test('getResult should throw StateError if type mismatch without resultConverter', () {
      final stage = ExperimentStageSelect<int>(
        id: id,
        options: [
          SelectOption(label: 'One', value: '1'),
        ],
      );
      expect(() => stage.getResult('1'), throwsA(isA<StateError>()));
    });

    testWidgets('ExperimentStageSelectWidget with custom generic type and converter completes correctly', (
      WidgetTester tester,
    ) async {
      int? completedResult;
      final stage = ExperimentStageSelect<int>(
        id: 'select_custom',
        question: 'Choose a number:',
        options: [
          SelectOption(label: 'Option 10', value: '10'),
          SelectOption(label: 'Option 20', value: '20'),
        ],
        resultConverter: (val) => int.parse(val),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExperimentStageSelectWidget<int>(
              key: const ValueKey('select_custom'),
              stage: stage,
              onComplete: (result) {
                completedResult = result;
              },
            ),
          ),
        ),
      );

      expect(find.text('Choose a number:'), findsOneWidget);
      expect(find.text('Option 10'), findsOneWidget);
      expect(find.text('Option 20'), findsOneWidget);

      // Tap Option 20
      await tester.tap(find.text('Option 20'));
      await tester.pumpAndSettle();

      // Tap Confirm
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(completedResult, equals(20));
    });
  });
}
