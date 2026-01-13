import 'package:json_annotation/json_annotation.dart';
import 'package:yahp_director/core/experiment/experiment.dart';
import 'package:yahp_director/core/serialization/serializable_conditional_directed_graph.dart';
import 'package:yahp_director/core/serialization/serializable_stage_converter.dart';
import '../experiment/experiment_stage.dart';

part 'serializable_experiment.g.dart';

@JsonSerializable(explicitToJson: true, createFactory: false)
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

  factory SerializableExperiment.fromJson(Map<String, dynamic> json) {
    final SerializableConditionalDirectedGraph transitions =
        SerializableConditionalDirectedGraph.fromJson(
            json['transitions'] as Map<String, dynamic>);
    final Map<String, ExperimentStage<String>> stages =
        (json['stages'] as Map<String, dynamic>).map(
            (String key, dynamic jsonStage) => MapEntry(
                key,
                ExperimentStageConverter()
                    .fromJson(jsonStage as Map<String, dynamic>)));
    return SerializableExperiment(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      stages: stages,
      serializableTransitions: transitions,
      initialStageId: json['startingStageId'] as String?,
      lastStageId: json['finalStageId'] as String?,
      cancelStageId: json['abortStageId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'stages': stages.map((key, stage) =>
            MapEntry(key, ExperimentStageConverter().toJson(stage))),
        'transitions': serializableTransitions.toJson(),
        'startingStageId': startingStageId,
        'finalStageId': finalStageId,
        'abortStageId': abortStageId,
      };
}
