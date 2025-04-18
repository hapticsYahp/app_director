import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_app/core/graph/trigger_never.dart';

void main() {
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
}
