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
    T_Input Function(Object? json) fromJsonTInput,
  ) =>
      _$TriggerLesserThanFromJson(json, fromJsonTInput);

  @override
  Map<String, dynamic> toJson(Object? Function(T_Input value) toJsonTInput) =>
      _$TriggerLesserThanToJson(this, toJsonTInput);

  @override
  String getJsonType() {
    return jsonType;
  }
}
