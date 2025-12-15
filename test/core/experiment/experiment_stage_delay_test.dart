import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:yahp_director/core/experiment/experiment.dart';
import 'package:yahp_director/core/experiment/experiment_stage_delay.dart';
import 'package:yahp_director/providers/poma/poma_client.dart';
import 'experiment_stage_delay_test.mocks.dart';
import 'test_experiment.dart';

@GenerateMocks([TestExperiment, PomaClient])
void main() {
  group('ExperimentStageDelay', () {
    final String id = 'delay_id';
    final String completionResult = 'COMPLETED';
    final String enterCommand = 'enter_command';
    final String exitCommand = 'exit_command';
    final String tickCommand1 = 'tick_command_1';
    final String tickCommand3 = 'tick_command_3';
    final String tickCommand5 = 'tick_command_5';
    final Map<String, String> pomaCommands = {
      'ENTER': enterCommand,
      'TICK_1000': tickCommand1,
      'TICK_3000': tickCommand3,
      'TICK_5000': tickCommand5,
      'EXIT': exitCommand,
    };
    final int minDelayMs = 5000;
    final int maxDelayMs = 10000;

    late MockTestExperiment mockExperiment;
    late MockPomaClient mockPomaClient;
    late ExperimentStageDelay<String> stage;

    setUp(() {
      mockExperiment = MockTestExperiment();
      mockPomaClient = MockPomaClient();
      when(mockExperiment.pomaClient).thenReturn(mockPomaClient);
      stage = ExperimentStageDelay<String>(
        id: id,
        completionResult: completionResult,
        pomaCommands: pomaCommands,
      );
    });

    test('should have correct default values', () {
      final stage = ExperimentStageDelay<String>(
        id: id,
        completionResult: completionResult,
      );
      expect(stage.id, equals(id));
      expect(stage.completionResult, equals(completionResult));
      expect(stage.title, isNotNull);
      expect(stage.description, isNotNull);
      expect(stage.minDelayMs, isNotNull);
      expect(stage.maxDelayMs, isNotNull);
      expect(stage.tickProgressMs, isNotNull);
      expect(stage.delayFeedback, isNotNull);
      expect(stage.pomaCommands, isNotNull);
    });

    test('should allow custom values', () {
      final String title = 'Delay Title';
      final String description = 'Delay Description';
      final int tickProgressMs = 200;
      final String delayFeedback = "Delay feedback";
      final stage = ExperimentStageDelay<String>(
        id: id,
        title: title,
        description: description,
        completionResult: completionResult,
        minDelayMs: minDelayMs,
        maxDelayMs: maxDelayMs,
        tickProgressMs: tickProgressMs,
        delayFeedback: delayFeedback,
        pomaCommands: pomaCommands,
      );
      expect(stage.title, equals(title));
      expect(stage.description, equals(description));
      expect(stage.minDelayMs, equals(minDelayMs));
      expect(stage.maxDelayMs, equals(maxDelayMs));
      expect(stage.tickProgressMs, equals(tickProgressMs));
      expect(stage.delayFeedback, equals(delayFeedback));
      expect(stage.pomaCommands, equals(pomaCommands));
    });

    test('should send ENTER command when stage is entered', () {
      stage.setExperiment(mockExperiment as Experiment<dynamic, String>);
      when(mockPomaClient.isConnected()).thenReturn(true);
      stage.onEnter();
      verify(mockExperiment.sendPomaCommand(enterCommand)).called(1);
    });

    test('should randomize delay when stage is entered', () {
      stage.setExperiment(mockExperiment as Experiment<dynamic, String>);
      when(mockPomaClient.isConnected()).thenReturn(true);
      stage.onEnter();
      expect(stage.delayMs, greaterThanOrEqualTo(minDelayMs));
      expect(stage.delayMs, lessThanOrEqualTo(maxDelayMs));
    });

    test('should send EXIT command when stage is exited', () {
      stage.setExperiment(mockExperiment as Experiment<dynamic, String>);
      when(mockPomaClient.isConnected()).thenReturn(true);
      stage.onExit();
      verify(mockExperiment.sendPomaCommand(exitCommand)).called(1);
    });

    test('should send TICK commands on specific ticks', () {
      stage.setExperiment(mockExperiment as Experiment<dynamic, String>);
      when(mockPomaClient.isConnected()).thenReturn(true);
      stage.onTick(3000);
      verify(mockExperiment.sendPomaCommand(tickCommand3)).called(1);
      stage.onTick(5000);
      verify(mockExperiment.sendPomaCommand(tickCommand5)).called(1);
      stage.onTick(7000);
      verifyNever(mockExperiment.sendPomaCommand(tickCommand1));
    });

    test('should handle formatted tick commands correctly', () {
      final String tickCommand1 = 'tick_command_1';
      final String tickCommand2 = 'tick_command_2';
      final String tickCommand3 = 'tick_command_3';
      final String tickCommand4 = 'tick_command_4';
      final Map<String, String> pomaCommands = {
        'TICK_0001': tickCommand1,
        'TICK_0020': tickCommand2,
        'TICK_0300': tickCommand3,
        'TICK_4000': tickCommand4,
      };
      final stage = ExperimentStageDelay<String>(
        id: id,
        completionResult: completionResult,
        pomaCommands: pomaCommands,
      );
      stage.setExperiment(mockExperiment as Experiment<dynamic, String>);
      when(mockPomaClient.isConnected()).thenReturn(true);
      stage.onTick(1);
      verify(mockExperiment.sendPomaCommand(tickCommand1)).called(1);
      stage.onTick(20);
      verify(mockExperiment.sendPomaCommand(tickCommand2)).called(1);
      stage.onTick(300);
      verify(mockExperiment.sendPomaCommand(tickCommand3)).called(1);
      stage.onTick(4000);
      verify(mockExperiment.sendPomaCommand(tickCommand4)).called(1);
    });
  });
}
