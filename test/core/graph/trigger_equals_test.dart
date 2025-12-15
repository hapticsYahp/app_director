import 'package:flutter_test/flutter_test.dart';
import 'package:yahp_director/core/graph/trigger_equals.dart';

void main() {
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
}
