import 'package:wifi_app/core/graph/trigger.dart';

class TriggerDistinct<T_Input> extends Trigger<T_Input> {
  final T_Input _notExpected;

  TriggerDistinct(this._notExpected);

  @override
  bool evaluate(T_Input input) => (input != _notExpected);
}
