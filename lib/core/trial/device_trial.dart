import 'package:json_annotation/json_annotation.dart';

part 'device_trial.g.dart';

@JsonSerializable()
class DeviceTrial {
  @JsonKey(name: "_id")
  final String id;

  final String nombre;

  DeviceTrial(this.id, this.nombre);

  factory DeviceTrial.fromJson(Map<String, dynamic> json) =>
      _$DeviceTrialFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceTrialToJson(this);
}
