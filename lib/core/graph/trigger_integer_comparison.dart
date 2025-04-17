import 'package:json_annotation/json_annotation.dart';
import 'trigger.dart';

abstract class TriggerIntegerComparison<T_Input> extends Trigger<T_Input> {
  static int _defaultParser(dynamic input) {
    if (input == null) return 0;
    if (input is int) return input;
    if (input is double) return input.toInt();
    final str = input.toString().trim();
    final parsed = int.tryParse(str);
    return parsed ?? 0;
  }

  final int compareTo;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final int Function(T_Input) _parser;

  const TriggerIntegerComparison(
    this.compareTo, {
    int Function(T_Input)? parser,
  }) : _parser = parser ?? _defaultParser;

  bool compare(int input, int compareTo);

  @override
  bool evaluate(T_Input input) => compare(_parser(input), compareTo);
}
