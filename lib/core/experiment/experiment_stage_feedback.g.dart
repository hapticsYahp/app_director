// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment_stage_feedback.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExperimentStageFeedback<T_Result> _$ExperimentStageFeedbackFromJson<T_Result>(
  Map<String, dynamic> json,
  T_Result Function(Object? json) fromJsonT_Result,
) =>
    ExperimentStageFeedback<T_Result>(
      id: json['id'] as String,
      title: json['title'] as String? ?? "Feedback",
      description:
          json['description'] as String? ?? "Please provide your feedback.",
      minScaleValue: (json['minScaleValue'] as num?)?.toInt() ?? 0,
      maxScaleValue: (json['maxScaleValue'] as num?)?.toInt() ?? 10,
      initialSelectedValue:
          (json['initialSelectedValue'] as num?)?.toInt() ?? 5,
      positiveLabel: json['positiveLabel'] as String? ?? "Yes",
      negativeLabel: json['negativeLabel'] as String? ?? "No",
      feedbackLabel: json['feedbackLabel'] as String? ??
          "Indicate the perceived intensity:",
      confirmLabel: json['confirmLabel'] as String? ?? "Confirm",
      defaultResult: fromJsonT_Result(json['defaultResult']),
      positiveIcon: json['positiveIcon'] == null
          ? Icons.thumb_up
          : const IconDataJsonConverter()
              .fromJson((json['positiveIcon'] as num).toInt()),
      negativeIcon: json['negativeIcon'] == null
          ? Icons.thumb_down
          : const IconDataJsonConverter()
              .fromJson((json['negativeIcon'] as num).toInt()),
      confirmIcon: json['confirmIcon'] == null
          ? Icons.check
          : const IconDataJsonConverter()
              .fromJson((json['confirmIcon'] as num).toInt()),
      pomaCommands: (json['pomaCommands'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$ExperimentStageFeedbackToJson<T_Result>(
  ExperimentStageFeedback<T_Result> instance,
  Object? Function(T_Result value) toJsonT_Result,
) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'pomaCommands': instance.pomaCommands,
      'minScaleValue': instance.minScaleValue,
      'maxScaleValue': instance.maxScaleValue,
      'initialSelectedValue': instance.initialSelectedValue,
      'positiveLabel': instance.positiveLabel,
      'negativeLabel': instance.negativeLabel,
      'feedbackLabel': instance.feedbackLabel,
      'confirmLabel': instance.confirmLabel,
      'defaultResult': toJsonT_Result(instance.defaultResult),
      'positiveIcon':
          const IconDataJsonConverter().toJson(instance.positiveIcon),
      'negativeIcon':
          const IconDataJsonConverter().toJson(instance.negativeIcon),
      'confirmIcon': const IconDataJsonConverter().toJson(instance.confirmIcon),
    };
