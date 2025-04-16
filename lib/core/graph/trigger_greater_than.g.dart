// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trigger_greater_than.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TriggerGreaterThan<T_Input> _$TriggerGreaterThanFromJson<T_Input>(
  Map<String, dynamic> json,
  T_Input Function(Object? json) fromJsonT_Input,
) =>
    TriggerGreaterThan<T_Input>(
      (json['expected'] as num).toInt(),
    );

Map<String, dynamic> _$TriggerGreaterThanToJson<T_Input>(
  TriggerGreaterThan<T_Input> instance,
  Object? Function(T_Input value) toJsonT_Input,
) =>
    <String, dynamic>{
      'expected': instance.expected,
    };
