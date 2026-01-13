import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yahp_director/core/experiment/experiment_stage.dart';
import '../../components/experiment_stages/experiment_stage_select_widget.dart';
import '../serialization/icon_data_json_converter.dart';

part 'experiment_stage_select.g.dart';

@JsonSerializable()
class SelectOption {
  final String label;
  final String value;
  final String? image; // 'assets/...'or 'https://...'.

  SelectOption({required this.label, required this.value, this.image});

  bool get isNetworkImage => image != null && image!.startsWith('https://');

  bool get isAssetImage => image != null && image!.startsWith('assets/');

  factory SelectOption.fromJson(Map<String, dynamic> json) =>
      _$SelectOptionFromJson(json);

  Map<String, dynamic> toJson() => _$SelectOptionToJson(this);
}

@JsonSerializable(genericArgumentFactories: true, explicitToJson: true)
@IconDataJsonConverter()
class ExperimentStageSelect<T_Result> extends ExperimentStage<T_Result> {
  static const String jsonType = 'select';

  final String question;
  final bool multipleSelection;
  final bool shuffleOptions;
  final List<SelectOption> options;

  // Botones
  final String confirmButtonLabel;
  final IconData confirmButtonIcon;
  final String clearButtonLabel;
  final IconData clearButtonIcon;

  ExperimentStageSelect({
    required super.id,
    super.title = "Select",
    super.description = "Choosing...",
    this.question = "Select an option:",
    this.multipleSelection = false,
    this.shuffleOptions = false,
    required this.options,
    this.confirmButtonLabel = "Confirm",
    this.confirmButtonIcon = Icons.check,
    this.clearButtonLabel = "Clear",
    this.clearButtonIcon = Icons.clear,
    super.pomaCommands = const {},
  });

  @override
  Widget buildWidget(
    BuildContext context,
    void Function(T_Result result) onResult,
  ) {
    return ExperimentStageSelectWidget(
      key: ValueKey(id),
      stage: this,
      onComplete: onResult,
    );
  }

  factory ExperimentStageSelect.fromJson(
    Map<String, dynamic> json,
    T_Result Function(Object? json) fromJsonTResult,
  ) => _$ExperimentStageSelectFromJson(json, fromJsonTResult);

  @override
  Map<String, dynamic> toJson(Object? Function(T_Result value) toJsonTResult) =>
      _$ExperimentStageSelectToJson(this, toJsonTResult);

  @override
  String getJsonType() => jsonType;
}
