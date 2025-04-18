// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment_stage_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExperimentStageMessage<T_Result> _$ExperimentStageMessageFromJson<T_Result>(
  Map<String, dynamic> json,
  T_Result Function(Object? json) fromJsonT_Result,
) =>
    ExperimentStageMessage<T_Result>(
      id: json['id'] as String,
      title: json['title'] as String? ?? "Message",
      description: json['description'] as String? ?? "",
      exitedResult: fromJsonT_Result(json['exitedResult']),
      message: json['message'] as String? ?? "Thank you.",
      pomaCommands: (json['pomaCommands'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$ExperimentStageMessageToJson<T_Result>(
  ExperimentStageMessage<T_Result> instance,
  Object? Function(T_Result value) toJsonT_Result,
) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'pomaCommands': instance.pomaCommands,
      'exitedResult': toJsonT_Result(instance.exitedResult),
      'message': instance.message,
    };
