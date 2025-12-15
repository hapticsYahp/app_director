import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:yahp_director/core/experiment/experiment_stage_message.dart';
import 'package:yahp_director/providers/poma/poma_client.dart';
import 'experiment_stage_message_test.mocks.dart';
import 'test_experiment.dart';

@GenerateMocks([TestExperiment, PomaClient])
void main() {
  group('ExperimentStageMessage', () {
    final String id = 'message_id';
    final String exitedResult = 'EXITED';
    final String enterCommand = 'enter_command';
    final String exitCommand = 'exit_command';
    final Map<String, String> pomaCommands = {
      'ENTER': enterCommand,
      'EXIT': exitCommand,
    };

    late MockTestExperiment mockExperiment;
    late MockPomaClient mockPomaClient;
    late ExperimentStageMessage<String> stage;

    setUp(() {
      mockExperiment = MockTestExperiment();
      mockPomaClient = MockPomaClient();
      when(mockExperiment.pomaClient).thenReturn(mockPomaClient);
      stage = ExperimentStageMessage<String>(
        id: id,
        exitedResult: exitedResult,
        pomaCommands: pomaCommands,
      );
    });

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
  });
}
