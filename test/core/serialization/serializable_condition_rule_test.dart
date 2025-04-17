import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_app/core/graph/trigger.dart';
import 'package:wifi_app/core/graph/trigger_always.dart';
import 'package:wifi_app/core/graph/trigger_never.dart';
import 'package:wifi_app/core/graph/trigger_equals.dart';
import 'package:wifi_app/core/graph/trigger_distinct.dart';
import 'package:wifi_app/core/graph/trigger_greater_than.dart';
import 'package:wifi_app/core/graph/trigger_lesser_than.dart';
import 'package:wifi_app/core/serialization/serializable_condition_rule.dart';

void main() {
  SerializableConditionRule getRule(Trigger<String> trigger) {
    return SerializableConditionRule('node_1', trigger, 'node_2');
  }

  group('SerializableConditionRule', () {
    test('should correctly round-trip TriggerAlways', () {
      final original = getRule(TriggerAlways<String>());
      final restored = SerializableConditionRule.fromJson(original.toJson());
      expect(restored.origin, equals(original.origin));
      expect(restored.destination, equals(original.destination));
      expect(restored.trigger, isA<TriggerAlways<String>>());

      expect(restored.evaluate('any_value'), isTrue);
      expect(restored.evaluate('other_value'), isTrue);
      expect(restored.evaluate(''), isTrue);
    });

    test('should correctly round-trip TriggerNever', () {
      final original = getRule(TriggerNever<String>());
      final restored = SerializableConditionRule.fromJson(original.toJson());
      expect(restored.origin, equals(original.origin));
      expect(restored.destination, equals(original.destination));
      expect(restored.trigger, isA<TriggerNever<String>>());

      expect(restored.evaluate('any_value'), isFalse);
      expect(restored.evaluate('other_value'), isFalse);
      expect(restored.evaluate(''), isFalse);
    });

    test('should correctly round-trip TriggerEquals', () {
      final String expected = 'expected_value';
      final String notExpected = 'other_value';
      final original = getRule(TriggerEquals<String>(expected));
      final restored = SerializableConditionRule.fromJson(original.toJson());
      expect(restored.origin, equals(original.origin));
      expect(restored.destination, equals(original.destination));
      expect(restored.trigger, isA<TriggerEquals<String>>());

      expect(restored.evaluate(expected), isTrue);
      expect(restored.evaluate(notExpected), isFalse);
    });

    test('should correctly round-trip TriggerDistinct', () {
      final String notExpected = 'not_expected_value';
      final String expected = 'other_value';
      final original = getRule(TriggerDistinct<String>(notExpected));
      final restored = SerializableConditionRule.fromJson(original.toJson());
      expect(restored.origin, equals(original.origin));
      expect(restored.destination, equals(original.destination));
      expect(restored.trigger, isA<TriggerDistinct<String>>());

      expect(restored.evaluate(notExpected), isFalse);
      expect(restored.evaluate(expected), isTrue);
    });

    test('should correctly round-trip TriggerGreaterThan', () {
      final int compareTo = 5;
      final original = getRule(TriggerGreaterThan<String>(compareTo));
      final restored = SerializableConditionRule.fromJson(original.toJson());
      expect(restored.origin, equals(original.origin));
      expect(restored.destination, equals(original.destination));
      expect(restored.trigger, isA<TriggerGreaterThan<String>>());

      expect(restored.evaluate('10'), isTrue);
      expect(restored.evaluate(compareTo.toString()), isFalse);
      expect(restored.evaluate('3'), isFalse);
    });

    test('should correctly round-trip TriggerLesserThan', () {
      final int compareTo = 15;
      final original = getRule(TriggerLesserThan<String>(compareTo));
      final restored = SerializableConditionRule.fromJson(original.toJson());
      expect(restored.origin, equals(original.origin));
      expect(restored.destination, equals(original.destination));
      expect(restored.trigger, isA<TriggerLesserThan<String>>());

      expect(restored.evaluate('5'), isTrue);
      expect(restored.evaluate(compareTo.toString()), isFalse);
      expect(restored.evaluate('25'), isFalse);
    });
  });
}
