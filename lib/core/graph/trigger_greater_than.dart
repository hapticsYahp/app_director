import 'package:json_annotation/json_annotation.dart';
import 'trigger_integer_comparison.dart';

part 'trigger_greater_than.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class TriggerGreaterThan<T_Input> extends TriggerIntegerComparison<T_Input> {
  static const String jsonType = 'greater_than';

  const TriggerGreaterThan(super.compareTo, {super.parser});

  @override
  bool compare(int input, int compareTo) {
    return input > compareTo;
  }

  factory TriggerGreaterThan.fromJson(
    Map<String, dynamic> json,
    T_Input Function(Object? json) fromJsonT_Input,
  ) =>
      _$TriggerGreaterThanFromJson(json, fromJsonT_Input);

  @override
  Map<String, dynamic> toJson(Object? Function(T_Input value) toJsonT_Input) =>
      _$TriggerGreaterThanToJson(this, toJsonT_Input);

  @override
  String getJsonType() {
    return jsonType;
  }
}
