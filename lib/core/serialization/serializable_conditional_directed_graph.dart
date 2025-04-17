import 'package:json_annotation/json_annotation.dart';
import '../graph/conditional_directed_graph.dart';

part 'serializable_conditional_directed_graph.g.dart';

@JsonSerializable()
class SerializableConditionalDirectedGraph
    extends ConditionalDirectedGraph<String, String> {
  SerializableConditionalDirectedGraph();

  factory SerializableConditionalDirectedGraph.fromJson(
          Map<String, dynamic> json) =>
      _$SerializableConditionalDirectedGraphFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SerializableConditionalDirectedGraphToJson(this);
}
