// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_trial.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubjectTrial _$SubjectTrialFromJson(Map<String, dynamic> json) => SubjectTrial(
  id: json['id'] as String,
  name: json['name'] as String,
  age: (json['age'] as num?)?.toInt(),
  gender: json['gender'] as String?,
  dominantHand: json['dominantHand'] as String?,
  heightCm: (json['heightCm'] as num?)?.toInt(),
  weightKg: (json['weightKg'] as num?)?.toDouble(),
  wristCircumferenceCm: (json['wristCircumferenceCm'] as num?)?.toDouble(),
);

Map<String, dynamic> _$SubjectTrialToJson(SubjectTrial instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'age': instance.age,
      'gender': instance.gender,
      'dominantHand': instance.dominantHand,
      'heightCm': instance.heightCm,
      'weightKg': instance.weightKg,
      'wristCircumferenceCm': instance.wristCircumferenceCm,
    };
