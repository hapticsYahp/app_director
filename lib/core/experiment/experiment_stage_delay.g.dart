// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment_stage_delay.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExperimentStageDelay<T_Result> _$ExperimentStageDelayFromJson<T_Result>(
  Map<String, dynamic> json,
  T_Result Function(Object? json) fromJsonT_Result,
) =>
    ExperimentStageDelay<T_Result>(
      id: json['id'] as String,
      title: json['title'] as String? ?? "Delay",
      description: json['description'] as String? ?? "Delaying...",
      completionResult: fromJsonT_Result(json['completionResult']),
      minDelayMs: (json['minDelayMs'] as num?)?.toInt() ?? 5_000,
      maxDelayMs: (json['maxDelayMs'] as num?)?.toInt() ?? 10_000,
      tickProgressMs: (json['tickProgressMs'] as num?)?.toInt() ?? 100,
      delayFeedback: json['delayFeedback'] as String? ?? "Starting in...",
      showProgressBar: json['showProgressBar'] as bool? ?? true,
      pomaCommands: (json['pomaCommands'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$ExperimentStageDelayToJson<T_Result>(
  ExperimentStageDelay<T_Result> instance,
  Object? Function(T_Result value) toJsonT_Result,
) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'pomaCommands': instance.pomaCommands,
      'completionResult': toJsonT_Result(instance.completionResult),
      'minDelayMs': instance.minDelayMs,
      'maxDelayMs': instance.maxDelayMs,
      'tickProgressMs': instance.tickProgressMs,
      'delayFeedback': instance.delayFeedback,
      'showProgressBar': instance.showProgressBar,
    };
