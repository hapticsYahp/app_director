import 'package:json_annotation/json_annotation.dart';

part 'subject_trial.g.dart';

@JsonSerializable()
class SubjectTrial {
  final String id;

  String name;
  int? age;
  String? gender;
  String? dominantHand;
  int? heightCm;
  double? weightKg;
  double? wristCircumferenceCm;

  SubjectTrial({
    required this.id,
    required this.name,
    this.age,
    this.gender,
    this.dominantHand,
    this.heightCm,
    this.weightKg,
    this.wristCircumferenceCm,
  });

  factory SubjectTrial.fromJson(Map<String, dynamic> json) =>
      _$SubjectTrialFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectTrialToJson(this);
}
