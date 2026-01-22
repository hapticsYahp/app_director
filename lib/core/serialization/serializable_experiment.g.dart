// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializable_experiment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$SerializableExperimentToJson(
  SerializableExperiment instance,
) => <String, dynamic>{
  'hasListeners': instance.hasListeners,
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'stages': instance.stages.map(
    (k, e) => MapEntry(k, const ExperimentStageConverter().toJson(e)),
  ),
  'startingStageId': instance.startingStageId,
  'finalStageId': instance.finalStageId,
  'abortStageId': instance.abortStageId,
  'currentStage': const ExperimentStageConverter().toJson(
    instance.currentStage,
  ),
  'canAdvance': instance.canAdvance,
  'transitions': instance.serializableTransitions.toJson(),
};
