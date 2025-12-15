import 'package:json_annotation/json_annotation.dart';
import '../graph/conditional_directed_graph.dart';
import 'package:yahp_director/core/serialization/serializable_condition_rule.dart';

part 'serializable_conditional_directed_graph.g.dart';

@JsonSerializable(explicitToJson: true)
class SerializableConditionalDirectedGraph
    extends ConditionalDirectedGraph<String, String> {
  @JsonKey(name: 'rules')
  List<SerializableConditionRule> get serializableRules {
    return rules
        .map((rule) => SerializableConditionRule(
            rule.origin, rule.trigger, rule.destination))
        .toList();
  }

  set serializableRules(List<SerializableConditionRule> rules) {
    for (final rule in rules) {
      addRule(rule.origin, rule.trigger, rule.destination);
    }
  }

  SerializableConditionalDirectedGraph(
      [List<SerializableConditionRule>? super.rules]);

  factory SerializableConditionalDirectedGraph.fromJson(
          Map<String, dynamic> json) =>
      _$SerializableConditionalDirectedGraphFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SerializableConditionalDirectedGraphToJson(this);
}
