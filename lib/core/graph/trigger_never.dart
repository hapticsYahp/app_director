import 'package:yahp_director/core/graph/trigger.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trigger_never.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class TriggerNever<T_Input> extends Trigger<T_Input> {
  static const String jsonType = 'never';

  const TriggerNever();

  factory TriggerNever.fromJson(
    Map<String, dynamic> json,
    T_Input Function(Object? json) fromJsonTInput,
  ) =>
      _$TriggerNeverFromJson(json, fromJsonTInput);

  @override
  Map<String, dynamic> toJson(Object? Function(T_Input value) toJsonTInput) =>
      _$TriggerNeverToJson(this, toJsonTInput);

  @override
  bool evaluate(T_Input input) => false;

  @override
  String getJsonType() {
    return jsonType;
  }
}
