// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializable_condition_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SerializableConditionRule _$SerializableConditionRuleFromJson(
        Map<String, dynamic> json) =>
    SerializableConditionRule(
      json['origin'] as String,
      const SerializableTriggerConverter()
          .fromJson(json['trigger'] as Map<String, dynamic>),
      json['destination'] as String,
    );

Map<String, dynamic> _$SerializableConditionRuleToJson(
        SerializableConditionRule instance) =>
    <String, dynamic>{
      'origin': instance.origin,
      'trigger': const SerializableTriggerConverter().toJson(instance.trigger),
      'destination': instance.destination,
    };
