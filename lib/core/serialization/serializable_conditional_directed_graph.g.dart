// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializable_conditional_directed_graph.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SerializableConditionalDirectedGraph
_$SerializableConditionalDirectedGraphFromJson(Map<String, dynamic> json) =>
    SerializableConditionalDirectedGraph()
      ..serializableRules = (json['rules'] as List<dynamic>)
          .map(
            (e) =>
                SerializableConditionRule.fromJson(e as Map<String, dynamic>),
          )
          .toList();

Map<String, dynamic> _$SerializableConditionalDirectedGraphToJson(
  SerializableConditionalDirectedGraph instance,
) => <String, dynamic>{
  'rules': instance.serializableRules.map((e) => e.toJson()).toList(),
};
