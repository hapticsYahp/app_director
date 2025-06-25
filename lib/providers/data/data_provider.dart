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

  /*
  -----------------------------------
  Experiments.
  -----------------------------------
   */

  Future<List<SerializableExperiment>> getExperiments() async {
    final Db db = await Db.create(config.dbUri);
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

  /*
  -----------------------------------
  Devices.
  -----------------------------------
   */

  Future<List<DeviceTrial>> getDevices() async {
    final Db db = await Db.create(config.dbUri);
    await db.open();
    final DbCollection devicesCollection = db.collection('devices');
    List<Map<String, dynamic>> devicesJson =
        await devicesCollection.find().toList();
    List<DeviceTrial> devices =
        devicesJson.map((devJson) => DeviceTrial.fromJson(devJson)).toList();
    await db.close();
    return devices;
  }

  Future<List<DeviceTrial>> searchDevicesByName(String name) async {
    final Db db = await Db.create(config.dbUri);
    await db.open();
    final DbCollection devicesCollection = db.collection('devices');
    final query = {
      'name': {'\$regex': name, '\$options': 'i'}
    };
    final List<Map<String, dynamic>> devicesJson =
        await devicesCollection.find(query).toList();
    final List<DeviceTrial> devices =
        devicesJson.map((json) => DeviceTrial.fromJson(json)).toList();
    await db.close();
    return devices;
  }

  Future<DeviceTrial> createDeviceTrial(String name) async {
    final Db db = await Db.create(config.dbUri);
    await db.open();
    final DbCollection devicesCollection = db.collection('devices');
    Map<String, dynamic> deviceJson = {
      'id': Uuid().v4(),
      'name': name,
    };
    final deviceJsonResult = await devicesCollection.insertOne(deviceJson);
    if (deviceJsonResult.isFailure) {
      throw deviceJsonResult.errmsg!;
    }
    await db.close();
    return DeviceTrial.fromJson(deviceJson);
  }

  Future<void> saveDevice(DeviceTrial device) async {
    final Db db = await Db.create(config.dbUri);
    await db.open();
    final DbCollection devicesCollection = db.collection('devices');
    await devicesCollection.updateOne(
      where.eq('id', device.id),
      modify.set('name', device.name),
    );
    await db.close();
  }

  /*
  -----------------------------------
  Subjects.
  -----------------------------------
   */

  Future<List<SubjectTrial>> getSubjects() async {
    final Db db = await Db.create(config.dbUri);
    await db.open();
    final DbCollection subjectsCollection = db.collection('subjects');
    List<Map<String, dynamic>> subjectsJson =
        await subjectsCollection.find().toList();
    List<SubjectTrial> subjects =
        subjectsJson.map((subJson) => SubjectTrial.fromJson(subJson)).toList();
    await db.close();
    return subjects;
  }

  Future<SubjectTrial> createSubjectTrial({
    String? name,
    int? age,
    String? gender,
    String? dominantHand,
    int? heightCm,
    double? weightKg,
    double? wristCircumferenceCm,
  }) async {
    final Db db = await Db.create(config.dbUri);
    await db.open();
    final DbCollection subjectsCollection = db.collection('subjects');
    if (name != null) {
      final count = await subjectsCollection.count();
      name = 'Subject #${count + 1}';
    }
    Map<String, dynamic> subjectJson = {
      'id': Uuid().v4(),
      'name': name,
      'age': age,
      'gender': gender,
      'dominantHand': dominantHand,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'wristCircumferenceCm': wristCircumferenceCm,
    };
    final subjectJsonResult = await subjectsCollection.insertOne(subjectJson);
    if (subjectJsonResult.isFailure) {
      throw subjectJsonResult.errmsg!;
    }
    await db.close();
    return SubjectTrial.fromJson(subjectJson);
  }

  Future<List<SubjectTrial>> searchSubjectsByName(String name) async {
    final Db db = await Db.create(config.dbUri);
    await db.open();
    final DbCollection subjectsCollection = db.collection('subjects');
    final query = {
      'name': {'\$regex': name, '\$options': 'i'}
    };
    final List<Map<String, dynamic>> subjectsJson =
        await subjectsCollection.find(query).toList();
    final List<SubjectTrial> subjects =
        subjectsJson.map((json) => SubjectTrial.fromJson(json)).toList();
    await db.close();
    return subjects;
  }

  Future<void> saveSubject(SubjectTrial subject) async {
    final Db db = await Db.create(config.dbUri);
    await db.open();
    final DbCollection subjectsCollection = db.collection('subjects');
    await subjectsCollection.updateOne(
      where.eq('id', subject.id),
      modify
          .set('name', subject.name)
          .set('age', subject.age)
          .set('gender', subject.gender)
          .set('dominantHand', subject.dominantHand)
          .set('heightCm', subject.heightCm)
          .set('weightKg', subject.weightKg)
          .set('wristCircumferenceCm', subject.wristCircumferenceCm),
    );
    await db.close();
  }

  /*
  -----------------------------------
  Trials.
  -----------------------------------
   */

  Future<ExperimentTrial> createTrial(
    Experiment experiment,
    SubjectTrial subject,
    DeviceTrial device,
  ) async {
    final Db db = await Db.create(config.dbUri);
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

  /*
  -----------------------------------
  Trial Events.
  -----------------------------------
   */

  Future<void> saveTrialEvents(ExperimentTrial trial) async {
    final List<Map<String, dynamic>> events = trial.getBufferedEvents();
    if (events.isNotEmpty) {
      final Db db = await Db.create(config.dbUri);
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
