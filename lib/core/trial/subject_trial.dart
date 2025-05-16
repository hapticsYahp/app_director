import 'package:json_annotation/json_annotation.dart';

part 'subject_trial.g.dart';

@JsonSerializable()
class SubjectTrial {
  @JsonKey(name: "_id")
  final String id;

  SubjectTrial(this.id);

  factory SubjectTrial.fromJson(Map<String, dynamic> json) =>
      _$SubjectTrialFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectTrialToJson(this);
}
