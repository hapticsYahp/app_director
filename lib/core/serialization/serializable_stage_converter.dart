import 'package:json_annotation/json_annotation.dart';
import 'package:wifi_app/core/experiment/experiment_stage.dart';
import 'package:wifi_app/core/experiment/experiment_stage_confirm.dart';
import 'package:wifi_app/core/experiment/experiment_stage_delay.dart';
import 'package:wifi_app/core/experiment/experiment_stage_feedback.dart';
import 'package:wifi_app/core/experiment/experiment_stage_message.dart';
import 'package:wifi_app/core/experiment/experiment_stage_wait.dart';
import 'base_converter.dart';

class ExperimentStageConverter extends BaseConverter
    implements JsonConverter<ExperimentStage<String>, Map<String, dynamic>> {
  const ExperimentStageConverter();

  @override
  ExperimentStage<String> fromJson(Map<String, dynamic> json) {
    fromJsonString(Object? json) => json.toString();
    final String type = json[jsonTypeKey] as String;
    switch (type) {
      case ExperimentStageConfirm.jsonType:
        return ExperimentStageConfirm.fromJson(json, fromJsonString);
      case ExperimentStageDelay.jsonType:
        return ExperimentStageDelay.fromJson(json, fromJsonString);
      case ExperimentStageFeedback.jsonType:
        return ExperimentStageFeedback.fromJson(json, fromJsonString);
      case ExperimentStageMessage.jsonType:
        return ExperimentStageMessage.fromJson(json, fromJsonString);
      case ExperimentStageWait.jsonType:
        return ExperimentStageWait.fromJson(json, fromJsonString);
      default:
        throw ArgumentError('Unknown ExperimentStage Json Type: $type');
    }
  }

  @override
  Map<String, dynamic> toJson(ExperimentStage<String> stage) {
    final json = stage.toJson((value) => value);
    json[jsonTypeKey] = stage.getJsonType();
    return json;
  }
}
