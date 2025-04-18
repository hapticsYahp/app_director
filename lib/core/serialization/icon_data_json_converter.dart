import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

class IconDataJsonConverter extends JsonConverter<IconData, int> {
  const IconDataJsonConverter();

  @override
  IconData fromJson(int json) {
    return IconData(json, fontFamily: 'MaterialIcons');
  }

  @override
  int toJson(IconData object) {
    return object.codePoint;
  }
}
