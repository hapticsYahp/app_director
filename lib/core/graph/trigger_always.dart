import 'package:wifi_app/core/graph/trigger.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trigger_always.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class TriggerAlways<T_Input> extends Trigger<T_Input> {
  static const String jsonType = 'always';

  const TriggerAlways();

  factory TriggerAlways.fromJson(
    Map<String, dynamic> json,
    T_Input Function(Object? json) fromJsonT_Input,
  ) =>
      _$TriggerAlwaysFromJson(json, fromJsonT_Input);

  @override
  Map<String, dynamic> toJson(Object? Function(T_Input value) toJsonT_Input) =>
      _$TriggerAlwaysToJson(this, toJsonT_Input);

  @override
  bool evaluate(T_Input input) => true;

  @override
  String getJsonType() {
    return jsonType;
  }
}
