import 'package:wifi_app/core/graph/trigger.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trigger_equals.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class TriggerEquals<T_Input> extends Trigger<T_Input> {
  static const String jsonType = 'equals';

  final T_Input expected;

  const TriggerEquals(this.expected);

  factory TriggerEquals.fromJson(
    Map<String, dynamic> json,
    T_Input Function(Object? json) fromJsonTInput,
  ) =>
      _$TriggerEqualsFromJson(json, fromJsonTInput);

  @override
  Map<String, dynamic> toJson(Object? Function(T_Input value) toJsonTInput) =>
      _$TriggerEqualsToJson(this, toJsonTInput);

  @override
  bool evaluate(T_Input input) => (input == expected);

  @override
  String getJsonType() {
    return jsonType;
  }
}
