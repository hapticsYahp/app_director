// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment_stage_wait.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExperimentStageWait<T_Result> _$ExperimentStageWaitFromJson<T_Result>(
  Map<String, dynamic> json,
  T_Result Function(Object? json) fromJsonT_Result,
) =>
    ExperimentStageWait<T_Result>(
      id: json['id'] as String,
      title: json['title'] as String? ?? "Wait",
      description: json['description'] as String? ?? "Waiting...",
      timeoutResult: fromJsonT_Result(json['timeoutResult']),
      feedbackResult: fromJsonT_Result(json['feedbackResult']),
      waitingMs: (json['waitingMs'] as num?)?.toInt() ?? 10_000,
      tickProgressMs: (json['tickProgressMs'] as num?)?.toInt() ?? 100,
      waitFeedback: json['waitFeedback'] as String? ?? "Time:",
      buttonLabel: json['buttonLabel'] as String? ?? "Feedback",
      buttonIcon: json['buttonIcon'] == null
          ? Icons.thumb_up
          : const IconDataJsonConverter()
              .fromJson((json['buttonIcon'] as num).toInt()),
      showProgressBar: json['showProgressBar'] as bool? ?? true,
      pomaCommands: (json['pomaCommands'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$ExperimentStageWaitToJson<T_Result>(
  ExperimentStageWait<T_Result> instance,
  Object? Function(T_Result value) toJsonT_Result,
) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'pomaCommands': instance.pomaCommands,
      'timeoutResult': toJsonT_Result(instance.timeoutResult),
      'feedbackResult': toJsonT_Result(instance.feedbackResult),
      'waitingMs': instance.waitingMs,
      'tickProgressMs': instance.tickProgressMs,
      'waitFeedback': instance.waitFeedback,
      'buttonLabel': instance.buttonLabel,
      'buttonIcon': const IconDataJsonConverter().toJson(instance.buttonIcon),
      'showProgressBar': instance.showProgressBar,
    };
