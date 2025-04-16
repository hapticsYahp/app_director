import 'package:json_annotation/json_annotation.dart';
import 'trigger_integer_comparison.dart';

part 'trigger_lesser_than.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class TriggerLesserThan<T_Input> extends TriggerIntegerComparison<T_Input> {
  const TriggerLesserThan(super.expected, {super.parser});

  @override
  bool compare(int input, int expected) {
    return input < expected;
  }

  factory TriggerLesserThan.fromJson(
    Map<String, dynamic> json,
    T_Input Function(Object? json) fromJsonT_Input,
  ) =>
      _$TriggerLesserThanFromJson(json, fromJsonT_Input);

  @override
  Map<String, dynamic> toJson(Object? Function(T_Input value) toJsonT_Input) =>
      _$TriggerLesserThanToJson(this, toJsonT_Input);
}
