import 'package:wifi_app/core/graph/trigger.dart';

class ConditionRule<T_Node, T_Trigger_Input> {
  final T_Node origin;
  final Trigger<T_Trigger_Input> trigger;
  final T_Node destination;

  ConditionRule(this.origin, this.trigger, this.destination);

  bool evaluate(T_Trigger_Input input) {
    return trigger.evaluate(input);
  }
}
