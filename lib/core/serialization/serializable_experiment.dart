import 'package:json_annotation/json_annotation.dart';
import 'package:wifi_app/core/experiment/experiment.dart';
import 'package:wifi_app/core/serialization/serializable_conditional_directed_graph.dart';
import 'package:wifi_app/core/serialization/serializable_stage_converter.dart';

part 'serializable_experiment.g.dart';

@JsonSerializable(explicitToJson: true)
@ExperimentStageConverter()
class SerializableExperiment extends Experiment<String, String> {
  @JsonKey(name: "transitions")
  final SerializableConditionalDirectedGraph serializableTransitions;

  SerializableExperiment({
    required super.id,
    required super.title,
    required super.description,
    required super.stages,
    required this.serializableTransitions,
    super.initialStageId,
    super.lastStageId,
    super.cancelStageId,
  }) : super(transitions: serializableTransitions);

  factory SerializableExperiment.fromJson(Map<String, dynamic> json) =>
      _$SerializableExperimentFromJson(json);

  Map<String, dynamic> toJson() => _$SerializableExperimentToJson(this);
}
