import 'package:wifi_app/core/graph/trigger.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trigger_distinct.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class TriggerDistinct<T_Input> extends Trigger<T_Input> {
  final T_Input notExpected;

  const TriggerDistinct(this.notExpected);

  factory TriggerDistinct.fromJson(
    Map<String, dynamic> json,
    T_Input Function(Object? json) fromJsonTInput,
  ) =>
      _$TriggerDistinctFromJson(json, fromJsonTInput);

  @override
  Map<String, dynamic> toJson(Object? Function(T_Input value) toJsonTInput) =>
      _$TriggerDistinctToJson(this, toJsonTInput);

  @override
  bool evaluate(T_Input input) => (input != notExpected);
}
