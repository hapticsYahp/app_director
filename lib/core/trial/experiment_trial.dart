import 'package:flutter/material.dart';
import 'package:wifi_app/core/trial/device_trial.dart';
import 'package:wifi_app/core/trial/subject_trial.dart';
import '../experiment/experiment.dart';

class ExperimentTrial {
  final String id;
  final Experiment experiment;
  final SubjectTrial subject;
  final DeviceTrial device;

  final List<Map<String, dynamic>> _eventsBuffer = [];

  ExperimentTrial(this.id, this.experiment, this.subject, this.device);

  void saveTrialEvent(String name,
      {Map<String, dynamic> extraData = const {}}) {
    final Map<String, dynamic> event = {
      'name': name,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    if (extraData.isNotEmpty) {
      event['extra'] = extraData;
    }
    _eventsBuffer.add(event);
    debugPrint("Buffered Event: '$name'.");
  }

  List<Map<String, dynamic>> getBufferedEvents() {
    return _eventsBuffer;
  }
}
