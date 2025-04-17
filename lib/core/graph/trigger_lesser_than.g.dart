// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trigger_lesser_than.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TriggerLesserThan<T_Input> _$TriggerLesserThanFromJson<T_Input>(
  Map<String, dynamic> json,
  T_Input Function(Object? json) fromJsonT_Input,
) =>
    TriggerLesserThan<T_Input>(
      (json['compareTo'] as num).toInt(),
    );

Map<String, dynamic> _$TriggerLesserThanToJson<T_Input>(
  TriggerLesserThan<T_Input> instance,
  Object? Function(T_Input value) toJsonT_Input,
) =>
    <String, dynamic>{
      'compareTo': instance.compareTo,
    };
