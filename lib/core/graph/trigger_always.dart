import 'package:wifi_app/core/graph/trigger.dart';

class TriggerAlways<T_Input> extends Trigger<T_Input> {
  @override
  bool evaluate(T_Input input) => true;
}
