// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment_stage_shuffle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExperimentStageShuffle<T_Result> _$ExperimentStageShuffleFromJson<T_Result>(
  Map<String, dynamic> json,
  T_Result Function(Object? json) fromJsonT_Result,
) => ExperimentStageShuffle<T_Result>(
  id: json['id'] as String,
  title: json['title'] as String? ?? "Shuffling",
  description: json['description'] as String? ?? "Choosing next stage...",
  stages: (json['stages'] as List<dynamic>).map((e) => e as String).toList(),
  completionResult: fromJsonT_Result(json['completionResult']),
  pomaCommands:
      (json['pomaCommands'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
);

Map<String, dynamic> _$ExperimentStageShuffleToJson<T_Result>(
  ExperimentStageShuffle<T_Result> instance,
  Object? Function(T_Result value) toJsonT_Result,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'pomaCommands': instance.pomaCommands,
  'stages': instance.stages,
  'completionResult': toJsonT_Result(instance.completionResult),
};
