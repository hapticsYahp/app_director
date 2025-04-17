import 'package:wifi_app/core/graph/trigger.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trigger_distinct.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class TriggerDistinct<T_Input> extends Trigger<T_Input> {
  static const String jsonType = 'distinct';

  final T_Input notExpected;

  const TriggerDistinct(this.notExpected);

  factory TriggerDistinct.fromJson(
    Map<String, dynamic> json,
    T_Input Function(Object? json) fromJsonT_Input,
  ) =>
      _$TriggerDistinctFromJson(json, fromJsonT_Input);

  Map<String, dynamic> toJson(Object? Function(T_Input value) toJsonT_Input) =>
      _$TriggerDistinctToJson(this, toJsonT_Input);

  @override
  bool evaluate(T_Input input) => (input != notExpected);

  @override
  String getJsonType() {
    return jsonType;
  }
}
