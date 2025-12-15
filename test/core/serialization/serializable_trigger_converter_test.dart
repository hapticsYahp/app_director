import 'package:flutter_test/flutter_test.dart';
import 'package:yahp_director/core/graph/trigger_always.dart';
import 'package:yahp_director/core/graph/trigger_never.dart';
import 'package:yahp_director/core/graph/trigger_equals.dart';
import 'package:yahp_director/core/graph/trigger_distinct.dart';
import 'package:yahp_director/core/graph/trigger_greater_than.dart';
import 'package:yahp_director/core/graph/trigger_lesser_than.dart';
import 'package:yahp_director/core/serialization/serializable_trigger_converter.dart';

void main() {
  late SerializableTriggerConverter converter;

  setUp(() {
    converter = const SerializableTriggerConverter();
  });

  group('SerializableTriggerConverter - fromJson', () {
    test('should correctly convert TriggerAlways', () {
      final json = {
        converter.jsonTypeKey: TriggerAlways.jsonType,
      };
      final trigger = converter.fromJson(json);
      expect(trigger, isA<TriggerAlways<String>>());

      expect(trigger.evaluate('any_value'), isTrue);
    });

    test('should correctly convert TriggerNever', () {
      final json = {
        converter.jsonTypeKey: TriggerNever.jsonType,
      };
      final trigger = converter.fromJson(json);
      expect(trigger, isA<TriggerNever<String>>());

      expect(trigger.evaluate('any_value'), isFalse);
    });

    test('should correctly convert TriggerEquals', () {
      final String expected = 'expected_value';
      final String notExpected = 'other_value';
      expect(expected, isNot(notExpected));

      final json = {
        converter.jsonTypeKey: TriggerEquals.jsonType,
        'expected': expected,
      };
      final trigger = converter.fromJson(json);
      expect(trigger, isA<TriggerEquals<String>>());

      expect(trigger.evaluate(expected), isTrue);
      expect(trigger.evaluate(notExpected), isFalse);
    });

    test('should correctly convert TriggerDistinct', () {
      final String notExpected = 'not_expected_value';
      final String otherValue = 'other_value';
      expect(notExpected, isNot(otherValue));

      final json = {
        converter.jsonTypeKey: TriggerDistinct.jsonType,
        'notExpected': notExpected,
      };
      final trigger = converter.fromJson(json);
      expect(trigger, isA<TriggerDistinct<String>>());

      expect(trigger.evaluate(notExpected), isFalse);
      expect(trigger.evaluate(otherValue), isTrue);
    });

    test('should correctly convert TriggerGreaterThan', () {
      final int compareTo = 10;
      final int greater = 15;
      final int lesser = 5;
      expect(lesser, lessThan(compareTo));
      expect(greater, greaterThan(compareTo));

      final json = {
        converter.jsonTypeKey: TriggerGreaterThan.jsonType,
        'compareTo': compareTo,
      };
      final trigger = converter.fromJson(json);
      expect(trigger, isA<TriggerGreaterThan<String>>());

      expect(trigger.evaluate(compareTo.toString()), isFalse);
      expect(trigger.evaluate(greater.toString()), isTrue);
      expect(trigger.evaluate(lesser.toString()), isFalse);
    });

    test('should correctly convert TriggerLesserThan', () {
      final int compareTo = 10;
      final int greater = 15;
      final int lesser = 5;
      expect(lesser, lessThan(compareTo));
      expect(greater, greaterThan(compareTo));

      final json = {
        converter.jsonTypeKey: TriggerLesserThan.jsonType,
        'compareTo': compareTo,
      };
      final trigger = converter.fromJson(json);
      expect(trigger, isA<TriggerLesserThan<String>>());

      expect(trigger.evaluate(compareTo.toString()), isFalse);
      expect(trigger.evaluate(greater.toString()), isFalse);
      expect(trigger.evaluate(lesser.toString()), isTrue);
    });

    test('should throw error with unknown type', () {
      final json = {
        converter.jsonTypeKey: 'unknown_type',
      };
      expect(() => converter.fromJson(json), throwsArgumentError);
    });
  });

  group('SerializableTriggerConverter - toJson', () {
    test('should correctly serialize TriggerAlways', () {
      final trigger = TriggerAlways<String>();
      final json = converter.toJson(trigger);
      expect(json[converter.jsonTypeKey], equals(TriggerAlways.jsonType));
    });

    test('should correctly serialize TriggerNever', () {
      final trigger = TriggerNever<String>();
      final json = converter.toJson(trigger);
      expect(json[converter.jsonTypeKey], equals(TriggerNever.jsonType));
    });

    test('should correctly serialize TriggerEquals', () {
      final String expected = 'expected_value';
      final trigger = TriggerEquals<String>(expected);
      final json = converter.toJson(trigger);
      expect(json[converter.jsonTypeKey], equals(TriggerEquals.jsonType));
      expect(json['expected'], equals(expected));
    });

    test('should correctly serialize TriggerDistinct', () {
      final String notExpected = 'not_expected_value';
      final trigger = TriggerDistinct<String>(notExpected);
      final json = converter.toJson(trigger);
      expect(json[converter.jsonTypeKey], equals(TriggerDistinct.jsonType));
      expect(json['notExpected'], equals(notExpected));
    });

    test('should correctly serialize TriggerGreaterThan', () {
      final int compareTo = 10;
      final trigger = TriggerGreaterThan<String>(compareTo);
      final json = converter.toJson(trigger);
      expect(json[converter.jsonTypeKey], equals(TriggerGreaterThan.jsonType));
      expect(json['compareTo'], equals(compareTo));
    });

    test('should correctly serialize TriggerLesserThan', () {
      final int compareTo = 10;
      final trigger = TriggerLesserThan<String>(compareTo);
      final json = converter.toJson(trigger);
      expect(json[converter.jsonTypeKey], equals(TriggerLesserThan.jsonType));
      expect(json['compareTo'], equals(compareTo));
    });

    test('should include type field for all triggers', () {
      final triggers = [
        TriggerAlways<String>(),
        TriggerNever<String>(),
        TriggerEquals<String>('value'),
        TriggerDistinct<String>('value'),
        TriggerGreaterThan<String>(10),
        TriggerLesserThan<String>(10),
      ];

      for (final trigger in triggers) {
        final json = converter.toJson(trigger);
        expect(json.containsKey(converter.jsonTypeKey), isTrue);
        expect(json[converter.jsonTypeKey], equals(trigger.getJsonType()));
      }
    });
  });

  group('SerializableTriggerConverter - Round-trip serialization', () {
    test('should correctly round-trip TriggerAlways', () {
      final original = TriggerAlways<String>();
      final restored = converter.fromJson(converter.toJson(original));
      expect(restored, isA<TriggerAlways<String>>());
      expect(restored.getJsonType(), equals(original.getJsonType()));

      final String anyValue = 'any_value';
      expect(restored.evaluate(anyValue), equals(original.evaluate(anyValue)));
    });

    test('should correctly round-trip TriggerNever', () {
      final original = TriggerNever<String>();
      final restored = converter.fromJson(converter.toJson(original));
      expect(restored, isA<TriggerNever<String>>());
      expect(restored.getJsonType(), equals(original.getJsonType()));

      final String anyValue = 'any_value';
      expect(restored.evaluate(anyValue), equals(original.evaluate(anyValue)));
    });

    test('should correctly round-trip TriggerEquals', () {
      final expectedValue = 'expected_value';
      final original = TriggerEquals<String>(expectedValue);
      final restored = converter.fromJson(converter.toJson(original));
      expect(restored, isA<TriggerEquals<String>>());
      expect(restored.getJsonType(), equals(original.getJsonType()));

      expect(restored.evaluate(expectedValue),
          equals(original.evaluate(expectedValue)));

      final differentValue = 'different_value';
      expect(differentValue, isNot(expectedValue));
      expect(restored.evaluate(differentValue),
          equals(original.evaluate(differentValue)));
    });

    test('should correctly round-trip TriggerDistinct', () {
      final notExpectedValue = 'not_expected_value';
      final original = TriggerDistinct<String>(notExpectedValue);
      final restored = converter.fromJson(converter.toJson(original));
      expect(restored, isA<TriggerDistinct<String>>());
      expect(restored.getJsonType(), equals(original.getJsonType()));

      expect(restored.evaluate(notExpectedValue),
          equals(original.evaluate(notExpectedValue)));

      final differentValue = 'different_value';
      expect(differentValue, isNot(notExpectedValue));
      expect(restored.evaluate(differentValue),
          equals(original.evaluate(differentValue)));
    });

    test('should correctly round-trip TriggerGreaterThan', () {
      final compareTo = 10;
      final original = TriggerGreaterThan<String>(compareTo);
      final restored = converter.fromJson(converter.toJson(original));
      expect(restored, isA<TriggerGreaterThan<String>>());
      expect(restored.getJsonType(), equals(original.getJsonType()));

      expect(restored.evaluate(compareTo.toString()),
          equals(original.evaluate(compareTo.toString())));

      final greaterValue = '15';
      expect(restored.evaluate(greaterValue),
          equals(original.evaluate(greaterValue)));

      final lesserValue = '5';
      expect(restored.evaluate(lesserValue),
          equals(original.evaluate(lesserValue)));
    });

    test('should correctly round-trip TriggerLesserThan', () {
      final compareTo = 10;
      final original = TriggerLesserThan<String>(compareTo);
      final restored = converter.fromJson(converter.toJson(original));
      expect(restored, isA<TriggerLesserThan<String>>());
      expect(restored.getJsonType(), equals(original.getJsonType()));

      expect(restored.evaluate(compareTo.toString()),
          equals(original.evaluate(compareTo.toString())));

      final greaterValue = '15';
      expect(restored.evaluate(greaterValue),
          equals(original.evaluate(greaterValue)));

      final lesserValue = '5';
      expect(restored.evaluate(lesserValue),
          equals(original.evaluate(lesserValue)));
    });
  });
}
