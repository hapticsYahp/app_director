// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment_stage_confirm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExperimentStageConfirm<T_Result> _$ExperimentStageConfirmFromJson<T_Result>(
  Map<String, dynamic> json,
  T_Result Function(Object? json) fromJsonT_Result,
) =>
    ExperimentStageConfirm<T_Result>(
      id: json['id'] as String,
      title: json['title'] as String? ?? "Confirm",
      description: json['description'] as String? ?? "Please confirm.",
      confirmationResult: fromJsonT_Result(json['confirmationResult']),
      buttonLabel: json['buttonLabel'] as String? ?? "Start",
      buttonIcon: json['buttonIcon'] == null
          ? Icons.play_arrow
          : const IconDataJsonConverter()
              .fromJson((json['buttonIcon'] as num).toInt()),
      pomaCommands: (json['pomaCommands'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$ExperimentStageConfirmToJson<T_Result>(
  ExperimentStageConfirm<T_Result> instance,
  Object? Function(T_Result value) toJsonT_Result,
) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'pomaCommands': instance.pomaCommands,
      'confirmationResult': toJsonT_Result(instance.confirmationResult),
      'buttonLabel': instance.buttonLabel,
      'buttonIcon': const IconDataJsonConverter().toJson(instance.buttonIcon),
    };
