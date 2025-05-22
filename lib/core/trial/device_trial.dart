import 'package:json_annotation/json_annotation.dart';

part 'device_trial.g.dart';

@JsonSerializable()
class DeviceTrial {
  final String id;

  String name;

  DeviceTrial(this.id, this.name);

  factory DeviceTrial.fromJson(Map<String, dynamic> json) =>
      _$DeviceTrialFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceTrialToJson(this);
}
