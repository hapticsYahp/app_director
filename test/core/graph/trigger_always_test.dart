import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_app/core/graph/trigger_always.dart';

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
}
