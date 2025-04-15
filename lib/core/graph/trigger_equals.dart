import 'package:wifi_app/core/graph/trigger.dart';

class TriggerEquals<T_Input> extends Trigger<T_Input> {
  final T_Input _expected;

  TriggerEquals(this._expected);

  @override
  bool evaluate(T_Input input) => (input == _expected);
}
