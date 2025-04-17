import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_app/core/graph/conditional_directed_graph.dart';
import 'package:wifi_app/core/graph/trigger_always.dart';
import 'package:wifi_app/core/graph/trigger_greater_than.dart';
import 'package:wifi_app/core/graph/trigger_lesser_than.dart';
import 'package:wifi_app/core/graph/trigger_never.dart';
import 'package:wifi_app/core/graph/trigger_equals.dart';
import 'package:wifi_app/core/graph/condition_rule.dart';

void main() {
  group('ConditionalDirectedGraph', () {
    final String node1 = 'node1';
    final String node2 = 'node2';
    final String node3 = 'node3';
    late ConditionalDirectedGraph<String, String> graph;

    setUp(() {
      graph = ConditionalDirectedGraph<String, String>();
    });

    test('should be created with no rules when no parameters are provided', () {
      final destinations = graph.getDestinationsFromOrigin(node1);
      expect(destinations, isEmpty);
      expect(graph.getDestination(node1, 'any_input'), isNull);
    });

    test('should be created with rules when provided in constructor', () {
      final rule1 =
          ConditionRule<String, String>(node1, TriggerAlways<String>(), node2);
      final rule2 =
          ConditionRule<String, String>(node2, TriggerNever<String>(), node3);
      final rules = [rule1, rule2];
      final graphWithRules = ConditionalDirectedGraph<String, String>(rules);
      expect(graphWithRules.rules, hasLength(2));
      expect(graphWithRules.rules.first.origin, equals(rule1.origin));
      expect(graphWithRules.rules.first.trigger, equals(rule1.trigger));
      expect(graphWithRules.rules.first.destination, equals(rule1.destination));
      expect(graphWithRules.rules.last.origin, equals(rule2.origin));
      expect(graphWithRules.rules.last.trigger, equals(rule2.trigger));
      expect(graphWithRules.rules.last.destination, equals(rule2.destination));
    });

    test('should create a defensive copy of rules in constructor', () {
      final rules = [
        ConditionRule<String, String>(node1, TriggerAlways<String>(), node2),
      ];
      final graphWithRules = ConditionalDirectedGraph<String, String>(rules);
      rules.add(
          ConditionRule<String, String>(node2, TriggerAlways<String>(), node3));
      expect(rules, hasLength(2));
      expect(graphWithRules.rules, hasLength(1));
      graphWithRules.addRule(node2, TriggerAlways<String>(), node3);
      expect(graphWithRules.rules, hasLength(2));
    });

    test('should add rules correctly', () {
      graph.addRule(node1, TriggerAlways<String>(), node2);
      final destinations = graph.getDestinationsFromOrigin(node1);
      expect(destinations, hasLength(1));

      final rule = destinations.first;
      expect(rule.origin, equals(node1));
      expect(rule.destination, equals(node2));
      expect(rule.trigger, isA<TriggerAlways<String>>());

      graph.addRule(node2, TriggerNever<String>(), node3);
      final destinations2 = graph.getDestinationsFromOrigin(node2);
      expect(destinations2, hasLength(1));

      final rule2 = destinations2.first;
      expect(rule2.origin, equals(node2));
      expect(rule2.destination, equals(node3));
      expect(rule2.trigger, isA<TriggerNever<String>>());
    });

    test('should add multiple rules for the same origin', () {
      graph.addRule(node1, TriggerAlways<String>(), node2);
      graph.addRule(node1, TriggerNever<String>(), node3);

      final destinations = graph.getDestinationsFromOrigin(node1);
      expect(destinations, hasLength(2));
    });

    test('should find the correct destination based on trigger input', () {
      final String input1 = 'input1';
      final String input2 = 'input2';
      final String otherInput = 'other_input';
      graph.addRule(node1, TriggerEquals<String>(input1), node2);
      graph.addRule(node2, TriggerNever<String>(), node1);
      graph.addRule(node2, TriggerEquals<String>(input2), node3);

      expect(graph.getDestination(node1, input1), equals(node2));
      expect(graph.getDestination(node2, input2), equals(node3));
      expect(graph.getDestination(node1, otherInput), isNot(node2));
      expect(graph.getDestination(node2, otherInput), isNot(node3));
    });

    test('should return null when no matching rule is found', () {
      graph.addRule(node1, TriggerNever<String>(), node2);
      expect(graph.getDestination(node1, 'any_input'), isNull);
    });

    test('should handle wildcard origin nodes', () {
      final String fallback = 'fallback';
      graph.addRule('*', TriggerAlways<String>(), fallback);
      graph.addRule(node1, TriggerEquals<String>('eq'), node2);
      expect(graph.getDestination(node1, 'any'), equals(fallback));
      expect(graph.getDestination(node3, 'any'), equals(fallback));
    });

    test('should consider rule order when evaluating destinations', () {
      graph.addRule(node1, TriggerAlways<String>(), node1);
      graph.addRule(node1, TriggerAlways<String>(), node2);
      expect(graph.getDestination(node1, 'any'), equals(node1));
    });

    test('should support different types for nodes and trigger inputs', () {
      final int compareTo = 5;
      final int nodeInt1 = 1;
      final int nodeInt2 = 2;
      final int nodeInt3 = 3;
      final numericGraph = ConditionalDirectedGraph<int, double>();

      // Add rules in reverse order to match behavior in test
      // The issue was that rules are evaluated in the order they're added
      // When the input is exactly equal to compareTo (5.0), both conditions fail
      numericGraph.addRule(
          nodeInt1, TriggerLesserThan<double>(compareTo), nodeInt3);
      numericGraph.addRule(
          nodeInt1, TriggerGreaterThan<double>(compareTo), nodeInt2);

      // Use values that are clearly greater/lesser to avoid boundary issues
      expect(numericGraph.getDestination(nodeInt1, compareTo + 1.0),
          equals(nodeInt2));
      expect(numericGraph.getDestination(nodeInt1, compareTo - 1.0),
          equals(nodeInt3));
    });

    test('should handle complex conditional routing scenarios', () {
      final String start = 'start';
      final String leftBranch = 'left_branch';
      final String rightBranch = 'right_branch';
      final String leftEnd = 'left_end';
      final String rightEnd = 'right_end';
      final String go = 'go';
      final String goLeft = 'go_left';
      final String goRight = 'go_right';
      graph.addRule(start, TriggerEquals<String>(goLeft), leftBranch);
      graph.addRule(start, TriggerEquals<String>(goRight), rightBranch);
      graph.addRule(leftBranch, TriggerEquals<String>(go), leftEnd);
      graph.addRule(rightBranch, TriggerEquals<String>(go), rightEnd);
      expect(graph.getDestination(start, goLeft), equals(leftBranch));
      expect(graph.getDestination(leftBranch, go), equals(leftEnd));
      expect(graph.getDestination(start, goRight), equals(rightBranch));
      expect(graph.getDestination(rightBranch, go), equals(rightEnd));
    });
  });
}
