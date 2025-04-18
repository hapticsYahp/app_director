import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_app/core/graph/trigger_distinct.dart';

void main() {
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
}
