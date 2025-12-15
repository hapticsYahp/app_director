import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yahp_director/core/experiment/experiment_stage.dart';
import '../../components/experiment_stages/experiment_stage_confirm_widget.dart';
import '../serialization/icon_data_json_converter.dart';

part 'experiment_stage_confirm.g.dart';

@JsonSerializable(genericArgumentFactories: true)
@IconDataJsonConverter()
class ExperimentStageConfirm<T_Result> extends ExperimentStage<T_Result> {
  static const String jsonType = 'confirm';

  final T_Result confirmationResult;
  final String buttonLabel;
  final IconData buttonIcon;

  ExperimentStageConfirm({
    required super.id,
    super.title = "Confirm",
    super.description = "Please confirm.",
    required this.confirmationResult,
    this.buttonLabel = "Start",
    this.buttonIcon = Icons.play_arrow,
    super.pomaCommands = const {},
  });

  @override
  Widget buildWidget(
    BuildContext context,
    void Function(T_Result result) onResult,
  ) {
    return ExperimentStageConfirmWidget(
      key: ValueKey(id),
      stage: this,
      onConfirm: onResult,
    );
  }

  factory ExperimentStageConfirm.fromJson(
    Map<String, dynamic> json,
    T_Result Function(Object? json) fromJsonTResult,
  ) =>
      _$ExperimentStageConfirmFromJson(json, fromJsonTResult);

  @override
  Map<String, dynamic> toJson(Object? Function(T_Result value) toJsonTResult) =>
      _$ExperimentStageConfirmToJson(this, toJsonTResult);

  @override
  String getJsonType() {
    return jsonType;
  }
}
