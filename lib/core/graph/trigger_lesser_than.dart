import 'trigger_integer_comparison.dart';

class TriggerLesserThan<T_Input> extends TriggerIntegerComparison<T_Input> {
  TriggerLesserThan(super.expected, {super.parser});

  @override
  bool compare(int input, int expected) {
    return input < expected;
  }
}
