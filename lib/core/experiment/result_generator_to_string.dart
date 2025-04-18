import 'package:json_annotation/json_annotation.dart';
import 'result_generator.dart';

part 'result_generator_to_string.g.dart';

@JsonSerializable()
class ResultGeneratorToString extends ResultGenerator<String> {
  static const String jsonType = 'toString';

  ResultGeneratorToString();

  @override
  String getResult(int value) => value.toString();

  @override
  String getJsonType() => jsonType;

  factory ResultGeneratorToString.fromJson(Map<String, dynamic> json) =>
      _$ResultGeneratorToStringFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ResultGeneratorToStringToJson(this);
}
