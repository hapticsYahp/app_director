import 'package:json_annotation/json_annotation.dart';
import 'package:wifi_app/core/serialization/base_converter.dart';
import '../experiment/result_generator.dart';
import '../experiment/result_generator_to_string.dart';

class ResultGeneratorConverter<T_Result> extends BaseConverter
    implements JsonConverter<ResultGenerator<T_Result>, Map<String, dynamic>> {
  const ResultGeneratorConverter();

  @override
  ResultGenerator<T_Result> fromJson(Map<String, dynamic> json) {
    final String type = json[jsonTypeKey] as String;
    switch (type) {
      case ResultGeneratorToString.jsonType:
        if (T_Result == String) {
          return ResultGeneratorToString.fromJson(json)
              as ResultGenerator<T_Result>;
        }
        throw ArgumentError(
            'ResultGeneratorToString can only be used with result type String.');
      default:
        throw ArgumentError('Unknown ResultGenerator type: $type');
    }
  }

  @override
  Map<String, dynamic> toJson(ResultGenerator<T_Result> generator) {
    final json = generator.toJson();
    json[jsonTypeKey] = generator.getJsonType();
    return json;
  }
}
