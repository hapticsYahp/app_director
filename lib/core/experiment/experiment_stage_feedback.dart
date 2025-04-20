import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wifi_app/core/experiment/experiment_stage.dart';
import 'package:wifi_app/core/experiment/result_generator.dart';
import '../../components/experiment_stages/experiment_stage_feedback_widget.dart';
import '../serialization/icon_data_json_converter.dart';
import '../serialization/result_generator_converter.dart';

part 'experiment_stage_feedback.g.dart';

@JsonSerializable(genericArgumentFactories: true, explicitToJson: true)
class ExperimentStageFeedback<T_Result> extends ExperimentStage<T_Result> {
  static const String jsonType = 'feedback';

  final int minScaleValue;
  final int maxScaleValue;
  final int initialSelectedValue;
  final String positiveLabel;
  final String negativeLabel;
  final String feedbackLabel;
  final String confirmLabel;

  @JsonKey(
    includeToJson: false,
    includeFromJson: false,
  )
  ResultGenerator<T_Result>? resultGenerator;

  final T_Result defaultResult;

  @IconDataJsonConverter()
  final IconData positiveIcon;

  @IconDataJsonConverter()
  final IconData negativeIcon;

  @IconDataJsonConverter()
  final IconData confirmIcon;

  ExperimentStageFeedback({
    required super.id,
    super.title = "Feedback",
    super.description = "Please provide your feedback.",
    this.minScaleValue = 0,
    this.maxScaleValue = 10,
    this.initialSelectedValue = 5,
    this.positiveLabel = "Yes",
    this.negativeLabel = "No",
    this.feedbackLabel = "Indicate the perceived intensity:",
    this.confirmLabel = "Confirm",
    this.resultGenerator,
    required this.defaultResult,
    this.positiveIcon = Icons.thumb_up,
    this.negativeIcon = Icons.thumb_down,
    this.confirmIcon = Icons.check,
    super.pomaCommands = const {},
  });

  T_Result getResult(int scaleValue) {
    return resultGenerator?.getResult(scaleValue) ?? defaultResult;
  }

  @override
  Widget buildWidget(
    BuildContext context,
    void Function(T_Result result) onResult,
  ) {
    return ExperimentStageFeedbackWidget(
      key: ValueKey(id),
      stage: this,
      onFeedback: onResult,
    );
  }

  factory ExperimentStageFeedback.fromJson(
    Map<String, dynamic> json,
    T_Result Function(Object? json) fromJsonTResult,
  ) {
    final result =
        _$ExperimentStageFeedbackFromJson<T_Result>(json, fromJsonTResult);
    final resultGeneratorJson =
        json['resultGenerator'] as Map<String, dynamic>?;
    if (resultGeneratorJson != null) {
      result.resultGenerator =
          ResultGeneratorConverter<T_Result>().fromJson(resultGeneratorJson);
    }
    return result;
  }

  @override
  Map<String, dynamic> toJson(Object? Function(T_Result value) toJsonTResult) {
    final base = _$ExperimentStageFeedbackToJson(this, toJsonTResult);
    if (resultGenerator != null) {
      base['resultGenerator'] =
          ResultGeneratorConverter<T_Result>().toJson(resultGenerator!);
    }
    return base;
  }

  @override
  String getJsonType() => jsonType;
}
