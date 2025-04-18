import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wifi_app/core/experiment/experiment_stage.dart';
import '../../components/experiment_stages/experiment_stage_message_widget.dart';

part 'experiment_stage_message.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ExperimentStageMessage<T_Result> extends ExperimentStage<T_Result> {
  static const String jsonType = 'message';

  final T_Result exitedResult;
  final String message;

  ExperimentStageMessage({
    required super.id,
    super.title = "Message",
    super.description = "",
    required this.exitedResult,
    this.message = "Thank you.",
    super.pomaCommands = const {},
  });

  @override
  Widget buildWidget(
    BuildContext context,
    void Function(T_Result result) onResult,
  ) {
    return ExperimentStageMessageWidget(
      key: ValueKey(id),
      stage: this,
      onComplete: onResult,
    );
  }

  factory ExperimentStageMessage.fromJson(
    Map<String, dynamic> json,
    T_Result Function(Object? json) fromJsonTResult,
  ) =>
      _$ExperimentStageMessageFromJson(json, fromJsonTResult);

  Map<String, dynamic> toJson(Object? Function(T_Result value) toJsonTResult) =>
      _$ExperimentStageMessageToJson(this, toJsonTResult);

  @override
  String getJsonType() {
    return jsonType;
  }
}
