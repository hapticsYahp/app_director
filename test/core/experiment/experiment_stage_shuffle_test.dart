import 'package:flutter_test/flutter_test.dart';
import 'package:yahp_director/core/experiment/experiment_stage_shuffle.dart';

void main() {
  group('ExperimentStageShuffle', () {
    test(
      'should return all stage IDs from pool exactly once in random order',
      () {
        final pool = ['a', 'b', 'c', 'd', 'e'];
        final stage = ExperimentStageShuffle<String>(
          id: 'shuffle',
          stages: pool,
          completionResult: 'COMPLETED',
        );

        final visited = <String>[];
        for (var i = 0; i < pool.length; i++) {
          final nextId = stage.getNextStageId();
          expect(nextId, isNotNull);
          expect(pool.contains(nextId), isTrue);
          expect(visited.contains(nextId), isFalse);
          visited.add(nextId!);
        }

        expect(stage.getNextStageId(), isNull);
        expect(visited, containsAll(pool));
      },
    );

    test('reset should clear visited stages', () {
      final pool = ['a', 'b'];
      final stage = ExperimentStageShuffle<String>(
        id: 'shuffle',
        stages: pool,
        completionResult: 'COMPLETED',
      );

      stage.getNextStageId();
      stage.getNextStageId();
      expect(stage.getNextStageId(), isNull);

      stage.reset();
      expect(stage.getNextStageId(), isNotNull);
    });

    test('toJson and fromJson should work correctly', () {
      final stage = ExperimentStageShuffle<String>(
        id: 'shuffle',
        stages: ['a', 'b'],
        completionResult: 'done',
      );

      final json = stage.toJson((v) => v);
      expect(json['id'], 'shuffle');
      expect(json['stages'], ['a', 'b']);
      expect(json['completionResult'], 'done');

      final fromJson = ExperimentStageShuffle.fromJson(
        json,
        (v) => v.toString(),
      );
      expect(fromJson.id, stage.id);
      expect(fromJson.stages, stage.stages);
      expect(fromJson.completionResult, stage.completionResult);
    });
  });
}
