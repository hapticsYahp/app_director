import 'package:mongo_dart/mongo_dart.dart';
import 'package:wifi_app/core/serialization/serializable_experiment.dart';
import 'package:wifi_app/providers/config/config_notifier.dart';

class DataProvider {
  final ConfigNotifier config;

  DataProvider(this.config);

  Future<List<SerializableExperiment>> getExperiments() async {
    final Db db = Db(config.dbUri);
    await db.open();
    final DbCollection experimentsColl = db.collection('experiments');
    List<Map<String, dynamic>> data = await experimentsColl.find().toList();
    List<SerializableExperiment> experiments =
        data.map((e) => SerializableExperiment.fromJson(e)).toList();
    await db.close();
    return experiments;
  }
}
