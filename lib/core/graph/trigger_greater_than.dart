import 'trigger_integer_comparison.dart';

class TriggerGreaterThan<T_Input> extends TriggerIntegerComparison<T_Input> {
  TriggerGreaterThan(super.expected, {super.parser});

  @override
  bool compare(int input, int expected) {
    return input > expected;
  }
}
