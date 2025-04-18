import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_app/core/graph/trigger_lesser_than.dart';

void main() {
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
