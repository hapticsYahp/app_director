import 'trigger.dart';

abstract class TriggerIntegerComparison<T_Input> extends Trigger<T_Input> {
  static int _defaultParser(dynamic input) =>
      int.tryParse(input.toString()) ?? 0;

  final int _expected;
  final int Function(T_Input) _parser;

  TriggerIntegerComparison(
    this._expected, {
    int Function(T_Input)? parser,
  }) : _parser = parser ?? _defaultParser;

  bool compare(int input, int expected);

  @override
  bool evaluate(T_Input input) => compare(_parser(input), _expected);
}
