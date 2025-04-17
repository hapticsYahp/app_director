import 'package:wifi_app/core/graph/trigger.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trigger_always.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class TriggerAlways<T_Input> extends Trigger<T_Input> {
  static const String jsonType = 'always';

  const TriggerAlways();

  factory TriggerAlways.fromJson(
    Map<String, dynamic> json,
    T_Input Function(Object? json) fromJsonTInput,
  ) =>
      _$TriggerAlwaysFromJson(json, fromJsonTInput);

  @override
  Map<String, dynamic> toJson(Object? Function(T_Input value) toJsonTInput) =>
      _$TriggerAlwaysToJson(this, toJsonTInput);

  @override
  bool evaluate(T_Input input) => true;

  @override
  String getJsonType() {
    return jsonType;
  }
}
