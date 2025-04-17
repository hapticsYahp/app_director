import 'package:collection/collection.dart';
import 'package:wifi_app/core/graph/trigger.dart';
import 'package:wifi_app/core/graph/condition_rule.dart';

class ConditionalDirectedGraph<T_Node, T_Trigger_Input> {
  final List<ConditionRule<T_Node, T_Trigger_Input>> _rules = [];

  void addRule(
      T_Node origin, Trigger<T_Trigger_Input> trigger, T_Node destination) {
    _rules.add(ConditionRule(origin, trigger, destination));
  }

  T_Node? getDestination(T_Node origin, T_Trigger_Input triggerInput) {
    return getDestinations(origin)
        .firstWhereOrNull((rule) => rule.evaluate(triggerInput))
        ?.destination;
  }

  List<ConditionRule<T_Node, T_Trigger_Input>> getDestinations(T_Node origin) {
    return _rules
        .where((t) => (t.origin == origin) || (t.origin == "*"))
        .toList();
  }
}
