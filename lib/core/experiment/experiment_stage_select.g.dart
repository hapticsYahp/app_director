// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment_stage_select.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SelectOption _$SelectOptionFromJson(Map<String, dynamic> json) => SelectOption(
  label: json['label'] as String,
  value: json['value'] as String,
);

Map<String, dynamic> _$SelectOptionToJson(SelectOption instance) =>
    <String, dynamic>{'label': instance.label, 'value': instance.value};

ExperimentStageSelect<T_Result> _$ExperimentStageSelectFromJson<T_Result>(
  Map<String, dynamic> json,
  T_Result Function(Object? json) fromJsonT_Result,
) => ExperimentStageSelect<T_Result>(
  id: json['id'] as String,
  title: json['title'] as String? ?? "Select",
  description: json['description'] as String? ?? "Choosing...",
  question: json['question'] as String? ?? "Select an option:",
  multipleSelection: json['multipleSelection'] as bool? ?? false,
  shuffleOptions: json['shuffleOptions'] as bool? ?? false,
  options: (json['options'] as List<dynamic>)
      .map((e) => SelectOption.fromJson(e as Map<String, dynamic>))
      .toList(),
  confirmButtonLabel: json['confirmButtonLabel'] as String? ?? "Confirm",
  confirmButtonIcon: json['confirmButtonIcon'] == null
      ? Icons.check
      : const IconDataJsonConverter().fromJson(
          (json['confirmButtonIcon'] as num).toInt(),
        ),
  clearButtonLabel: json['clearButtonLabel'] as String? ?? "Clear",
  clearButtonIcon: json['clearButtonIcon'] == null
      ? Icons.clear
      : const IconDataJsonConverter().fromJson(
          (json['clearButtonIcon'] as num).toInt(),
        ),
  pomaCommands:
      (json['pomaCommands'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
);

Map<String, dynamic> _$ExperimentStageSelectToJson<T_Result>(
  ExperimentStageSelect<T_Result> instance,
  Object? Function(T_Result value) toJsonT_Result,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'pomaCommands': instance.pomaCommands,
  'question': instance.question,
  'multipleSelection': instance.multipleSelection,
  'shuffleOptions': instance.shuffleOptions,
  'options': instance.options.map((e) => e.toJson()).toList(),
  'confirmButtonLabel': instance.confirmButtonLabel,
  'confirmButtonIcon': const IconDataJsonConverter().toJson(
    instance.confirmButtonIcon,
  ),
  'clearButtonLabel': instance.clearButtonLabel,
  'clearButtonIcon': const IconDataJsonConverter().toJson(
    instance.clearButtonIcon,
  ),
};
