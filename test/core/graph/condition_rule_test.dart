import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_app/core/graph/condition_rule.dart';
import 'package:wifi_app/core/graph/trigger_always.dart';
import 'package:wifi_app/core/graph/trigger_equals.dart';
import 'package:wifi_app/core/graph/trigger_never.dart';
import 'package:wifi_app/core/graph/trigger_greater_than.dart';
import 'package:wifi_app/core/graph/trigger_lesser_than.dart';

void main() {
  group('ConditionRule', () {
    const String originNode = 'origin';
    const String destinationNode = 'destination';

    test('should create a rule with correct properties', () {
      final trigger = TriggerAlways<String>();
      final rule =
          ConditionRule<String, String>(originNode, trigger, destinationNode);

      expect(rule.origin, equals(originNode));
      expect(rule.trigger, equals(trigger));
      expect(rule.destination, equals(destinationNode));
    });

    test('should evaluate to true with TriggerAlways', () {
      final rule = ConditionRule<String, String>(
          originNode, TriggerAlways<String>(), destinationNode);
      expect(rule.evaluate('any_input'), isTrue);
      expect(rule.evaluate(''), isTrue);
      expect(rule.evaluate('different_input'), isTrue);
    });

    test('should evaluate to false with TriggerNever', () {
      final rule = ConditionRule<String, String>(
          originNode, TriggerNever<String>(), destinationNode);
      expect(rule.evaluate('any_input'), isFalse);
      expect(rule.evaluate(''), isFalse);
      expect(rule.evaluate('different_input'), isFalse);
    });

    test('should evaluate correctly with TriggerEquals', () {
      const String matchValue = 'match_me';
      final rule = ConditionRule<String, String>(
          originNode, TriggerEquals<String>(matchValue), destinationNode);
      expect(rule.evaluate(matchValue), isTrue);
      expect(rule.evaluate('different_value'), isFalse);
    });

    test('should evaluate correctly with TriggerGreaterThan', () {
      const int threshold = 10;
      final rule = ConditionRule<String, String>(
          originNode, TriggerGreaterThan<String>(threshold), destinationNode);
      expect(rule.evaluate('15'), isTrue);
      expect(rule.evaluate('100'), isTrue);
      expect(rule.evaluate('10'), isFalse);
      expect(rule.evaluate('5'), isFalse);
      expect(rule.evaluate('not_a_number'), isFalse);
    });

    test('should evaluate correctly with TriggerLesserThan', () {
      const int threshold = 10;
      final rule = ConditionRule<String, String>(
          originNode, TriggerLesserThan<String>(threshold), destinationNode);
      expect(rule.evaluate('5'), isTrue);
      expect(rule.evaluate('0'), isTrue);
      expect(rule.evaluate('10'), isFalse);
      expect(rule.evaluate('15'), isFalse);
      expect(rule.evaluate('not_a_number'), isTrue); // same as 0.
    });

    test('should work with different generic types', () {
      final int node1 = 1;
      final int node2 = 2;
      final numericRule = ConditionRule<int, double>(
          node1, TriggerGreaterThan<double>(5), node2);
      expect(numericRule.origin, equals(node1));
      expect(numericRule.destination, equals(node2));
      expect(numericRule.evaluate(10.0), isTrue);
      expect(numericRule.evaluate(3.0), isFalse);
    });
  });
}
