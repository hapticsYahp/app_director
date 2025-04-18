// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializable_experiment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SerializableExperiment _$SerializableExperimentFromJson(
        Map<String, dynamic> json) =>
    SerializableExperiment(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      stages: (json['stages'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            const ExperimentStageConverter()
                .fromJson(e as Map<String, dynamic>)),
      ),
      serializableTransitions: SerializableConditionalDirectedGraph.fromJson(
          json['transitions'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SerializableExperimentToJson(
        SerializableExperiment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'stages': instance.stages.map(
          (k, e) => MapEntry(k, const ExperimentStageConverter().toJson(e))),
      'transitions': instance.serializableTransitions.toJson(),
    };
