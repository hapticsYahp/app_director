import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi_app/core/serialization/serializable_experiment.dart';
import 'package:wifi_app/core/trial/device_trial.dart';
import 'package:wifi_app/core/trial/experiment_trial.dart';
import 'package:wifi_app/core/trial/subject_trial.dart';
import 'package:wifi_app/providers/config/config_notifier.dart';
import '../../core/experiment/experiment.dart';

class DataProvider {
  final ConfigNotifier config;

  DataProvider(this.config);

  Future<List<SerializableExperiment>> getExperiments() async {
    final Db db = Db(config.dbUri);
    await db.open();
    final DbCollection experimentsCollection = db.collection('experiments');
    List<Map<String, dynamic>> experimentsJson =
        await experimentsCollection.find().toList();
    List<SerializableExperiment> experiments = experimentsJson
        .map((expJson) => SerializableExperiment.fromJson(expJson))
        .toList();
    await db.close();
    return experiments;
  }

  Future<List<DeviceTrial>> getDevices() async {
    final Db db = Db(config.dbUri);
    await db.open();
    final DbCollection devicesCollection = db.collection('devices');
    List<Map<String, dynamic>> devicesJson =
        await devicesCollection.find().toList();
    List<DeviceTrial> devices =
        devicesJson.map((devJson) => DeviceTrial.fromJson(devJson)).toList();
    await db.close();
    return devices;
  }

  Future<List<SubjectTrial>> getSubjects() async {
    final Db db = Db(config.dbUri);
    await db.open();
    final DbCollection subjectsCollection = db.collection('subjects');
    List<Map<String, dynamic>> subjectsJson =
        await subjectsCollection.find().toList();
    List<SubjectTrial> subjects =
        subjectsJson.map((subJson) => SubjectTrial.fromJson(subJson)).toList();
    await db.close();
    return subjects;
  }

  Future<SubjectTrial> createSubjectTrial() async {
    final Db db = Db(config.dbUri);
    await db.open();
    final DbCollection subjectsCollection = db.collection('subjects');
    Map<String, dynamic> subjectJson = {
      '_id': Uuid().v4(),
    };
    final subjectJsonResult = await subjectsCollection.insertOne(subjectJson);
    if (subjectJsonResult.isFailure) {
      throw subjectJsonResult.errmsg!;
    }
    await db.close();
    return SubjectTrial.fromJson(subjectJson);
  }

  Future<DeviceTrial> createDeviceTrial() async {
    final Db db = Db(config.dbUri);
    await db.open();
    final DbCollection devicesCollection = db.collection('devices');
    Map<String, dynamic> deviceJson = {
      '_id': Uuid().v4(),
    };
    final deviceJsonResult = await devicesCollection.insertOne(deviceJson);
    if (deviceJsonResult.isFailure) {
      throw deviceJsonResult.errmsg!;
    }
    await db.close();
    return DeviceTrial.fromJson(deviceJson);
  }

  Future<ExperimentTrial> createTrial(
    Experiment experiment,
    SubjectTrial subject,
    DeviceTrial device,
  ) async {
    final Db db = Db(config.dbUri);
    await db.open();
    final DbCollection trialsCollection = db.collection('trials');
    final ObjectId id = ObjectId();
    final trialJsonResult = await trialsCollection.insertOne({
      '_id': id,
      'experimentId': experiment.id,
      'subjectId': subject.id,
      'deviceId': device.id,
      'events': [],
    });
    if (trialJsonResult.isFailure) {
      throw trialJsonResult.errmsg!;
    }
    await db.close();
    return ExperimentTrial(id.oid, experiment, subject, device);
  }

  Future<void> saveTrialEvents(ExperimentTrial trial) async {
    final List<Map<String, dynamic>> events = trial.getBufferedEvents();
    if (events.isNotEmpty) {
      final Db db = Db(config.dbUri);
      await db.open();
      final DbCollection trialsCollection = db.collection('trials');
      try {
        await trialsCollection.updateOne(
          where.id(ObjectId.fromHexString(trial.id)),
          modify.set('events', events),
        );
        debugPrint("Saved ${events.length} events to DB.");
      } catch (e, stack) {
        debugPrint("Error saving to DB: $e");
        debugPrintStack(stackTrace: stack);
      }
      await db.close();
    }
  }
}
