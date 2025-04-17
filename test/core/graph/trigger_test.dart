import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_app/core/graph/trigger_always.dart';
import 'package:wifi_app/core/graph/trigger_never.dart';
import 'package:wifi_app/core/graph/trigger_equals.dart';
import 'package:wifi_app/core/graph/trigger_distinct.dart';
import 'package:wifi_app/core/graph/trigger_greater_than.dart';
import 'package:wifi_app/core/graph/trigger_lesser_than.dart';

void main() {
  group('TriggerAlways', () {
    test('should always evaluate to true regardless of input', () {
      final trigger = TriggerAlways<String>();
      expect(trigger.evaluate('any string'), isTrue);
      expect(trigger.evaluate(''), isTrue);
    });

    test('should work with different data types', () {
      // Integer test.
      final intTrigger = TriggerAlways<int>();
      expect(intTrigger.evaluate(42), isTrue);
      expect(intTrigger.evaluate(43), isTrue);

      // Double test.
      final doubleTrigger = TriggerAlways<double>();
      expect(doubleTrigger.evaluate(3.14), isTrue);
      expect(doubleTrigger.evaluate(2.71), isTrue);

      // Boolean test.
      final boolTrigger = TriggerAlways<bool>();
      expect(boolTrigger.evaluate(true), isTrue);
      expect(boolTrigger.evaluate(false), isTrue);
    });
  });

  group('TriggerNever', () {
    test('should always evaluate to false regardless of input', () {
      final trigger = TriggerNever<String>();
      expect(trigger.evaluate('any string'), isFalse);
      expect(trigger.evaluate(''), isFalse);
    });

    test('should work with different data types', () {
      // Integer test.
      final intTrigger = TriggerNever<int>();
      expect(intTrigger.evaluate(42), isFalse);
      expect(intTrigger.evaluate(43), isFalse);

      // Double test.
      final doubleTrigger = TriggerNever<double>();
      expect(doubleTrigger.evaluate(3.14), isFalse);
      expect(doubleTrigger.evaluate(2.71), isFalse);

      // Boolean test.
      final boolTrigger = TriggerNever<bool>();
      expect(boolTrigger.evaluate(true), isFalse);
      expect(boolTrigger.evaluate(false), isFalse);
    });
  });

  group('TriggerEquals', () {
    test('should evaluate to true only when input equals expected value', () {
      final expectedValue = 'expected_value';
      final differentValue = 'different_value';
      expect(expectedValue, isNot(differentValue));
      final trigger = TriggerEquals<String>(expectedValue);
      expect(trigger.evaluate(expectedValue), isTrue);
      expect(trigger.evaluate(differentValue), isFalse);
    });

    test('should work with different data types', () {
      // Integer test.
      final expectedInt = 42;
      final intTrigger = TriggerEquals<int>(expectedInt);
      expect(intTrigger.evaluate(expectedInt), isTrue);
      expect(intTrigger.evaluate(expectedInt + 1), isFalse);

      // Double test.
      final expectedFloat = 3.14;
      final doubleTrigger = TriggerEquals<double>(expectedFloat);
      expect(doubleTrigger.evaluate(expectedFloat), isTrue);
      expect(doubleTrigger.evaluate(expectedFloat + 4.14), isFalse);

      // Boolean test.
      final expectedBool = true;
      final boolTrigger = TriggerEquals<bool>(expectedBool);
      expect(boolTrigger.evaluate(expectedBool), isTrue);
      expect(boolTrigger.evaluate(!expectedBool), isFalse);
    });

    test('should handle null expected value', () {
      final trigger = TriggerEquals<String?>(null);
      expect(trigger.evaluate(null), isTrue);
      expect(trigger.evaluate('any_string'), isFalse);
    });
  });

  group('TriggerDistinct', () {
    test('should evaluate to true only when input differs from expected value',
        () {
      final notExpectedValue = 'not_expected_value';
      final differentValue = 'different_value';
      expect(notExpectedValue, isNot(differentValue));
      final trigger = TriggerDistinct<String>(notExpectedValue);
      expect(trigger.evaluate(notExpectedValue), isFalse);
      expect(trigger.evaluate(differentValue), isTrue);
    });

    test('should work with different data types', () {
      // Integer test.
      final notExpectedInt = 42;
      final intTrigger = TriggerDistinct<int>(notExpectedInt);
      expect(intTrigger.evaluate(notExpectedInt), isFalse);
      expect(intTrigger.evaluate(notExpectedInt + 1), isTrue);

      // Double test.
      final notExpectedFloat = 3.14;
      final doubleTrigger = TriggerDistinct<double>(notExpectedFloat);
      expect(doubleTrigger.evaluate(notExpectedFloat), isFalse);
      expect(doubleTrigger.evaluate(notExpectedFloat + 4.14), isTrue);

      // Boolean test.
      final notExpectedBool = true;
      final boolTrigger = TriggerDistinct<bool>(notExpectedBool);
      expect(boolTrigger.evaluate(notExpectedBool), isFalse);
      expect(boolTrigger.evaluate(!notExpectedBool), isTrue);
    });

    test('should handle null not-expected value', () {
      final trigger = TriggerDistinct<String?>(null);
      expect(trigger.evaluate(null), isFalse);
      expect(trigger.evaluate('any_string'), isTrue);
    });
  });

  group('TriggerGreaterThan', () {
    test(
        'should evaluate to true when numeric input is greater than ref. value',
        () {
      final compareTo = 10;
      final trigger = TriggerGreaterThan<int>(compareTo);
      expect(trigger.evaluate(compareTo + 300), isTrue);
      expect(trigger.evaluate(compareTo + 3), isTrue);
      expect(trigger.evaluate(compareTo), isFalse);
      expect(trigger.evaluate(compareTo - 3), isFalse);
      expect(trigger.evaluate(compareTo - 105), isFalse);
    });

    test('should convert string input to number for comparison', () {
      final compareTo = 10;
      final trigger = TriggerGreaterThan<String>(compareTo);
      expect(trigger.evaluate('15'), isTrue);
      expect(trigger.evaluate(compareTo.toString()), isFalse);
      expect(trigger.evaluate('5'), isFalse);
    });

    test('should handle non-numeric string input as 0', () {
      final compareTo = 10;
      final trigger = TriggerGreaterThan<String>(compareTo);
      expect(trigger.evaluate('not_a_number'), isFalse);
    });

    test('should handle null input', () {
      final trigger = TriggerGreaterThan<String?>(10);
      expect(trigger.evaluate(null), isFalse);
    });
  });

  group('TriggerLesserThan', () {
    test('should evaluate to true when numeric input is less than ref. value',
        () {
      final compareTo = 10;
      final trigger = TriggerLesserThan<int>(compareTo);
      expect(trigger.evaluate(compareTo - 1), isTrue);
      expect(trigger.evaluate(compareTo - compareTo), isTrue);
      expect(trigger.evaluate(compareTo - 102), isTrue);
      expect(trigger.evaluate(compareTo), isFalse);
      expect(trigger.evaluate(compareTo + 4), isFalse);
    });

    test('should convert string input to number for comparison', () {
      final compareTo = 10;
      final trigger = TriggerLesserThan<String>(compareTo);
      expect(trigger.evaluate('5'), isTrue);
      expect(trigger.evaluate(compareTo.toString()), isFalse);
      expect(trigger.evaluate('15'), isFalse);
    });

    test('should handle non-numeric string input as 0', () {
      final compareTo = 10;
      final trigger = TriggerLesserThan<String>(compareTo);
      expect(trigger.evaluate('not_a_number'), isTrue);
    });

    test('TriggerLesserThan should handle null input', () {
      final trigger = TriggerLesserThan<String?>(10);
      expect(trigger.evaluate(null), isTrue);
    });
  });
}
