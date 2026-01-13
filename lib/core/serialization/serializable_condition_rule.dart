import 'package:json_annotation/json_annotation.dart';
import 'package:yahp_director/core/serialization/serializable_trigger_converter.dart';
import '../graph/condition_rule.dart';

part 'serializable_condition_rule.g.dart';

@JsonSerializable()
@SerializableTriggerConverter()
class SerializableConditionRule extends ConditionRule<String, String> {
  SerializableConditionRule(super.origin, super.trigger, super.destination);

  factory SerializableConditionRule.fromJson(Map<String, dynamic> json) =>
      _$SerializableConditionRuleFromJson(json);

  Map<String, dynamic> toJson() => _$SerializableConditionRuleToJson(this);
}
