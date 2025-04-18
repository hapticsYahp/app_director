import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_app/core/graph/trigger_greater_than.dart';

void main() {
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
}
