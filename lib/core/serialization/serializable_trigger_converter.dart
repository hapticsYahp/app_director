import 'package:json_annotation/json_annotation.dart';
import 'package:wifi_app/core/graph/trigger.dart';
import 'package:wifi_app/core/graph/trigger_always.dart';
import 'package:wifi_app/core/graph/trigger_distinct.dart';
import 'package:wifi_app/core/graph/trigger_greater_than.dart';
import 'package:wifi_app/core/graph/trigger_lesser_than.dart';

import '../graph/trigger_equals.dart';
import '../graph/trigger_never.dart';
import 'base_converter.dart';

class SerializableTriggerConverter extends BaseConverter
    implements JsonConverter<Trigger<String>, Map<String, dynamic>> {
  const SerializableTriggerConverter();

  @override
  Trigger<String> fromJson(Map<String, dynamic> json) {
    fromJsonString(Object? json) => json.toString();
    final String type = json[jsonTypeKey] as String;
    switch (type) {
      case TriggerAlways.jsonType:
        return TriggerAlways<String>.fromJson(json, fromJsonString);
      case TriggerNever.jsonType:
        return TriggerNever<String>.fromJson(json, fromJsonString);
      case TriggerDistinct.jsonType:
        return TriggerDistinct<String>.fromJson(json, fromJsonString);
      case TriggerEquals.jsonType:
        return TriggerEquals<String>.fromJson(json, fromJsonString);
      case TriggerGreaterThan.jsonType:
        return TriggerGreaterThan<String>.fromJson(json, fromJsonString);
      case TriggerLesserThan.jsonType:
        return TriggerLesserThan<String>.fromJson(json, fromJsonString);
      default:
        throw ArgumentError('Unknown Trigger Json Type: $type');
    }
  }

  @override
  Map<String, dynamic> toJson(Trigger<String> trigger) {
    toJsonString(String value) => value;
    final Map<String, dynamic> json = trigger.toJson(toJsonString);
    json[jsonTypeKey] = trigger.getJsonType();
    return json;
  }
}
