// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trigger_equals.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TriggerEquals<T_Input> _$TriggerEqualsFromJson<T_Input>(
  Map<String, dynamic> json,
  T_Input Function(Object? json) fromJsonT_Input,
) =>
    TriggerEquals<T_Input>(
      fromJsonT_Input(json['expected']),
    );

Map<String, dynamic> _$TriggerEqualsToJson<T_Input>(
  TriggerEquals<T_Input> instance,
  Object? Function(T_Input value) toJsonT_Input,
) =>
    <String, dynamic>{
      'expected': toJsonT_Input(instance.expected),
    };
