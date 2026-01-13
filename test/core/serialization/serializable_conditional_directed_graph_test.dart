import 'package:flutter_test/flutter_test.dart';
import 'package:yahp_director/core/graph/trigger_always.dart';
import 'package:yahp_director/core/graph/trigger_equals.dart';
import 'package:yahp_director/core/graph/trigger_greater_than.dart';
import 'package:yahp_director/core/graph/trigger_lesser_than.dart';
import 'package:yahp_director/core/graph/trigger_never.dart';
import 'package:yahp_director/core/serialization/serializable_conditional_directed_graph.dart';
import 'package:yahp_director/core/serialization/serializable_condition_rule.dart';

void main() {
  group('SerializableConditionalDirectedGraph', () {
    final String node1 = 'node1';
    final String node2 = 'node2';
    final String node3 = 'node3';
    late SerializableConditionalDirectedGraph graph;

    setUp(() {
      graph = SerializableConditionalDirectedGraph();
    });

    test('should correctly round-trip with no rules', () {
      final restoredGraph =
          SerializableConditionalDirectedGraph.fromJson(graph.toJson());
      expect(restoredGraph.rules, isEmpty);
      expect(restoredGraph.getDestinationsFromOrigin('any'), isEmpty);
    });

    test('should correctly round-trip with rules initialization in constructor',
        () {
      final String input = 'input';
      final rules = [
        SerializableConditionRule(node1, TriggerAlways<String>(), node2),
        SerializableConditionRule(node2, TriggerEquals<String>(input), node3)
      ];
      final graphWithRules = SerializableConditionalDirectedGraph(rules);
      final restoredGraph = SerializableConditionalDirectedGraph.fromJson(
          graphWithRules.toJson());
      expect(restoredGraph.rules.length, equals(graphWithRules.rules.length));
      expect(restoredGraph.rules.first.origin,
          equals(graphWithRules.rules.first.origin));
      expect(restoredGraph.rules.first.trigger.runtimeType,
          equals(graphWithRules.rules.first.trigger.runtimeType));
      expect(restoredGraph.rules.first.destination,
          equals(graphWithRules.rules.first.destination));
      expect(restoredGraph.rules.last.origin,
          equals(graphWithRules.rules.last.origin));
      expect(
          (restoredGraph.rules.last.trigger as TriggerEquals<String>).expected,
          equals((graphWithRules.rules.last.trigger as TriggerEquals<String>)
              .expected));
      expect(restoredGraph.rules.last.destination,
          equals(graphWithRules.rules.last.destination));
      expect(restoredGraph.getDestination(node1, input),
          equals(graphWithRules.getDestination(node1, input)));
      expect(restoredGraph.getDestination(node2, input),
          graphWithRules.getDestination(node2, input));
    });

    test('should round-trip rules correctly', () {
      final String eqValue = 'specific_value';
      final String anyValue = 'any_value';
      graph.addRule(node1, TriggerAlways<String>(), node2);
      graph.addRule(node1, TriggerEquals<String>(eqValue), 'eq_dest');
      graph.addRule(node3, TriggerNever<String>(), 'never_dest');
      final restoredGraph =
          SerializableConditionalDirectedGraph.fromJson(graph.toJson());
      expect(graph.getDestination(node1, anyValue), equals(node2));
      expect(restoredGraph.getDestination(node1, anyValue), equals(node2));
      expect(graph.getDestination(node1, eqValue), equals(node2));
      expect(restoredGraph.getDestination(node1, eqValue), equals(node2));
      expect(graph.getDestination(node3, anyValue), isNull);
      expect(restoredGraph.getDestination(node3, anyValue), isNull);
    });

    test('should preserve rule order during round-trip serialization', () {
      final String value1 = 'value1';
      final String value2 = 'value2';
      graph.addRule(node1, TriggerEquals<String>(value1), node2);
      graph.addRule(node1, TriggerEquals<String>(value2), node3);
      final restoredGraph =
          SerializableConditionalDirectedGraph.fromJson(graph.toJson());
      expect(restoredGraph.getDestination(node1, value1),
          equals(graph.getDestination(node1, value1)));
      expect(restoredGraph.getDestination(node1, value2),
          equals(graph.getDestination(node1, value2)));
    });

    test('should round-trip complex graph structure', () {
      final String start = 'start';
      final String leftBranch = 'left_branch';
      final String rightBranch = 'right_branch';
      final String leftEnd = 'left_end';
      final String rightEnd = 'right_end';
      final String fallback = 'fallback';
      final String go = 'go';
      final String goLeft = 'go_left';
      final String goRight = 'go_right';
      graph.addRule(start, TriggerEquals<String>(goLeft), leftBranch);
      graph.addRule(start, TriggerEquals<String>(goRight), rightBranch);
      graph.addRule(leftBranch, TriggerEquals<String>(go), leftEnd);
      graph.addRule(rightBranch, TriggerEquals<String>(go), rightEnd);
      graph.addRule('*', TriggerAlways<String>(), fallback);
      final restoredGraph =
          SerializableConditionalDirectedGraph.fromJson(graph.toJson());
      expect(restoredGraph.getDestination(start, goLeft), equals(leftBranch));
      expect(restoredGraph.getDestination(leftBranch, go), equals(leftEnd));
      expect(restoredGraph.getDestination(start, goRight), equals(rightBranch));
      expect(restoredGraph.getDestination(rightBranch, go), equals(rightEnd));
      expect(restoredGraph.getDestination('unknown', 'any'), equals(fallback));
    });

    test('should correctly round-trip numeric triggers', () {
      graph.addRule(node1, TriggerGreaterThan<String>(10), node2);
      graph.addRule(node1, TriggerLesserThan<String>(5), node3);
      final restoredGraph =
          SerializableConditionalDirectedGraph.fromJson(graph.toJson());
      final String high = '15';
      expect(restoredGraph.getDestination(node1, high),
          equals(graph.getDestination(node1, high)));
      final String low = '3';
      expect(restoredGraph.getDestination(node1, low),
          equals(graph.getDestination(node1, low)));
      final String middle = '7';
      expect(restoredGraph.getDestination(node1, middle),
          equals(graph.getDestination(node1, middle)));
    });
  });
}
