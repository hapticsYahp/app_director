import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi_app/providers/poma/poma_client.dart';
import 'experiment_stage_test.mocks.dart';
import 'test_experiment.dart';
import 'test_experiment_stage.dart';


@GenerateMocks([TestExperiment, PomaClient])
void main() {
  group('ExperimentStage Base Class', () {
    final String id = 'mock_id';
    final String title = 'Mock Stage';
    final String description = 'Mock Description';
    final String enterCommand = 'enter_command';
    final String exitCommand = 'exit_command';
    final String tickCommand = 'tick_command';
    final Map<String, String> pomaCommands = {
      'ENTER': enterCommand,
      'TICK_1000': tickCommand,
      'EXIT': exitCommand,
    };

    late TestExperimentStage stage;
    late MockTestExperiment mockExperiment;
    late MockPomaClient mockPomaClient;

    setUp(() {
      stage = TestExperimentStage(
        id: id,
        title: title,
        description: description,
        pomaCommands: pomaCommands,
      );
      mockExperiment = MockTestExperiment();
      mockPomaClient = MockPomaClient();
      when(mockExperiment.pomaClient).thenReturn(mockPomaClient);
    });

    test('should have correct initialization values', () {
      expect(stage.id, equals(id));
      expect(stage.title, equals(title));
      expect(stage.description, equals(description));
      expect(stage.pomaCommands, equals(pomaCommands));
    });

    test('setExperiment should associate the stage with an experiment', () {
      stage.setExperiment(mockExperiment);
      expect(stage.experiment, equals(mockExperiment));
    });

    test('onEnter should send PoMA command via experiment', () {
      stage.setExperiment(mockExperiment);
      when(mockPomaClient.isConnected()).thenReturn(true);
      stage.onEnter();
      verify(mockExperiment.sendPomaCommand(enterCommand)).called(1);
    });

    test('onExit should send PoMA command via experiment', () {
      stage.setExperiment(mockExperiment);
      when(mockPomaClient.isConnected()).thenReturn(true);
      stage.onExit();
      verify(mockExperiment.sendPomaCommand(exitCommand)).called(1);
    });

    test('onTick should send PoMA command via experiment when tick matches',
        () {
      stage.setExperiment(mockExperiment);
      when(mockPomaClient.isConnected()).thenReturn(true);
      stage.onTick(1_000);
      verify(mockExperiment.sendPomaCommand(tickCommand)).called(1);
    });

    test('onTick should not send PoMA command when tick does not match', () {
      stage.setExperiment(mockExperiment);
      when(mockPomaClient.isConnected()).thenReturn(true);
      stage.onTick(5_000);
      verifyNever(mockExperiment.sendPomaCommand(any));
    });

    test('should handle missing experiment gracefully', () {
      expect(() => stage.onEnter(), returnsNormally);
      expect(() => stage.onExit(), returnsNormally);
      expect(() => stage.onTick(10), returnsNormally);
    });
  });
}
