import 'package:json_annotation/json_annotation.dart';
import 'trigger_integer_comparison.dart';

part 'trigger_lesser_than.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class TriggerLesserThan<T_Input> extends TriggerIntegerComparison<T_Input> {
  static const String jsonType = 'lesser_than';

  const TriggerLesserThan(super.compareTo, {super.parser});

  @override
  bool compare(int input, int compareTo) {
    return input < compareTo;
  }

  factory TriggerLesserThan.fromJson(
    Map<String, dynamic> json,
    T_Input Function(Object? json) fromJsonT_Input,
  ) =>
      _$TriggerLesserThanFromJson(json, fromJsonT_Input);

  @override
  Map<String, dynamic> toJson(Object? Function(T_Input value) toJsonT_Input) =>
      _$TriggerLesserThanToJson(this, toJsonT_Input);

  @override
  String getJsonType() {
    return jsonType;
  }
}
