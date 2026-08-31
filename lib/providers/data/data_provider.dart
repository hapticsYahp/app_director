import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:uuid/uuid.dart';
import 'package:yahp_director/core/serialization/serializable_experiment.dart';
import 'package:yahp_director/core/trial/device_trial.dart';
import 'package:yahp_director/core/trial/experiment_trial.dart';
import 'package:yahp_director/core/trial/subject_trial.dart';
import 'package:yahp_director/providers/config/config_notifier.dart';
import '../../core/experiment/experiment.dart';

class DataProvider {
  final ConfigNotifier config;
  Db? _db;
  String? _connectedDbUri;

  DataProvider(this.config);

  /// Returns an open Db instance, reusing the existing connection if possible
  /// and connected to the current configured URI.
  Future<Db> _getDb() async {
    final String currentUri = config.dbUri;

    if (_db != null && (_connectedDbUri != currentUri || !_isDbOpen(_db!))) {
      await _closeDb();
    }

    if (_db == null) {
      final db = await Db.create(currentUri);
      await db.open();
      _db = db;
      _connectedDbUri = currentUri;
    }

    return _db!;
  }

  bool _isDbOpen(Db db) {
    return db.isConnected;
  }

  Future<void> _closeDb() async {
    if (_db != null) {
      try {
        if (_db!.isConnected) {
          await _db!.close();
        }
      } catch (e) {
        debugPrint("Error closing DB: $e");
      } finally {
        _db = null;
        _connectedDbUri = null;
      }
    }
  }

  /// Executes an operation on the database with error handling and connection recovery.
  Future<T> _withDb<T>(Future<T> Function(Db db) action) async {
    Db db;
    try {
      db = await _getDb();
    } catch (e) {
      await _closeDb();
      rethrow;
    }

    try {
      return await action(db);
    } catch (e) {
      if (!_isDbOpen(db)) {
        await _closeDb();
      }
      rethrow;
    }
  }

  /// Closes any active database connection and releases resources.
  Future<void> dispose() async {
    await _closeDb();
  }

  /*
  -----------------------------------
  Experiments.
  -----------------------------------
   */

  Future<List<SerializableExperiment>> getExperiments() async {
    return _withDb((db) async {
      final DbCollection experimentsCollection = db.collection('experiments');
      final List<Map<String, dynamic>> experimentsJson =
          await experimentsCollection.find().toList();
      return experimentsJson
          .map((expJson) => SerializableExperiment.fromJson(expJson))
          .toList();
    });
  }

  /*
  -----------------------------------
  Devices.
  -----------------------------------
   */

  Future<List<DeviceTrial>> getDevices() async {
    return _withDb((db) async {
      final DbCollection devicesCollection = db.collection('devices');
      final List<Map<String, dynamic>> devicesJson = await devicesCollection
          .find()
          .toList();
      return devicesJson
          .map((devJson) => DeviceTrial.fromJson(devJson))
          .toList();
    });
  }

  Future<List<DeviceTrial>> searchDevicesByName(String name) async {
    return _withDb((db) async {
      final DbCollection devicesCollection = db.collection('devices');
      final query = {
        'name': {'\$regex': name, '\$options': 'i'},
      };
      final List<Map<String, dynamic>> devicesJson = await devicesCollection
          .find(query)
          .toList();
      return devicesJson.map((json) => DeviceTrial.fromJson(json)).toList();
    });
  }

  Future<DeviceTrial> createDeviceTrial(String name) async {
    return _withDb((db) async {
      final DbCollection devicesCollection = db.collection('devices');
      final Map<String, dynamic> deviceJson = {
        'id': const Uuid().v4(),
        'name': name,
      };
      final deviceJsonResult = await devicesCollection.insertOne(deviceJson);
      if (deviceJsonResult.isFailure) {
        throw deviceJsonResult.errmsg ?? 'Failed to create device';
      }
      return DeviceTrial.fromJson(deviceJson);
    });
  }

  Future<void> saveDevice(DeviceTrial device) async {
    return _withDb((db) async {
      final DbCollection devicesCollection = db.collection('devices');
      await devicesCollection.updateOne(
        where.eq('id', device.id),
        modify.set('name', device.name),
      );
    });
  }

  /*
  -----------------------------------
  Subjects.
  -----------------------------------
   */

  Future<List<SubjectTrial>> getSubjects() async {
    return _withDb((db) async {
      final DbCollection subjectsCollection = db.collection('subjects');
      final List<Map<String, dynamic>> subjectsJson = await subjectsCollection
          .find()
          .toList();
      return subjectsJson
          .map((subJson) => SubjectTrial.fromJson(subJson))
          .toList();
    });
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
    return _withDb((db) async {
      final DbCollection subjectsCollection = db.collection('subjects');
      String finalName = name ?? '';
      if (finalName.trim().isEmpty) {
        final count = await subjectsCollection.count();
        finalName = 'Subject #${count + 1}';
      }
      final Map<String, dynamic> subjectJson = {
        'id': const Uuid().v4(),
        'name': finalName,
        'age': age,
        'gender': gender,
        'dominantHand': dominantHand,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'wristCircumferenceCm': wristCircumferenceCm,
      };
      final subjectJsonResult = await subjectsCollection.insertOne(subjectJson);
      if (subjectJsonResult.isFailure) {
        throw subjectJsonResult.errmsg ?? 'Failed to create subject';
      }
      return SubjectTrial.fromJson(subjectJson);
    });
  }

  Future<List<SubjectTrial>> searchSubjectsByName(String name) async {
    return _withDb((db) async {
      final DbCollection subjectsCollection = db.collection('subjects');
      final query = {
        'name': {'\$regex': name, '\$options': 'i'},
      };
      final List<Map<String, dynamic>> subjectsJson = await subjectsCollection
          .find(query)
          .toList();
      return subjectsJson.map((json) => SubjectTrial.fromJson(json)).toList();
    });
  }

  Future<void> saveSubject(SubjectTrial subject) async {
    return _withDb((db) async {
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
    });
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
    return _withDb((db) async {
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
        throw trialJsonResult.errmsg ?? 'Failed to create trial';
      }
      return ExperimentTrial(id.oid, experiment, subject, device);
    });
  }

  /*
  -----------------------------------
  Trial Events.
  -----------------------------------
   */

  Future<void> saveTrialEvents(ExperimentTrial trial) async {
    final List<Map<String, dynamic>> events = trial.getBufferedEvents();
    if (events.isNotEmpty) {
      try {
        await _withDb((db) async {
          final DbCollection trialsCollection = db.collection('trials');
          await trialsCollection.updateOne(
            where.id(ObjectId.fromHexString(trial.id)),
            modify.set('events', events),
          );
          debugPrint("Saved ${events.length} events to DB.");
        });
      } catch (e, stack) {
        debugPrint("Error saving to DB: $e");
        debugPrintStack(stackTrace: stack);
      }
    }
  }
}
