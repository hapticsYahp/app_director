import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'experiment.dart';

abstract class ExperimentStage<T_Result> {
  final String id;
  final String title;
  final String description;
  final Map<String, String> pomaCommands;

  @JsonKey(includeFromJson: false, includeToJson: false)
  Experiment<dynamic, T_Result>? experiment;

  ExperimentStage({
    required this.id,
    required this.title,
    required this.description,
    this.pomaCommands = const {},
  });

  void setExperiment(Experiment<dynamic, T_Result> experiment) {
    this.experiment = experiment;
  }

  void _pomaCallback(String eventKey) {
    if (pomaCommands.containsKey(eventKey)) {
      experiment?.sendPomaCommand(pomaCommands[eventKey]!);
    }
  }

  void onEnter() {
    _pomaCallback("ENTER");
  }

  void onExit() {
    _pomaCallback("EXIT");
  }

  void onTick(int milliseconds) {
    _pomaCallback("TICK_${milliseconds.toString().padLeft(4, '0')}");
  }

  Widget buildWidget(
    BuildContext context,
    void Function(T_Result result) onResult,
  );

  Map<String, dynamic> toJson(Object? Function(T_Result value) toJsonTResult);

  String getJsonType();
}
