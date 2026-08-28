import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yahp_director/providers/config/config_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'ConfigNotifier uses dotenv fallback when SharedPreferences is empty',
    () async {
      dotenv.load(
        mergeWith: {'MONGODB_CONN_STR': 'mongodb://env_host:27017/env_db'},
      );
      SharedPreferences.setMockInitialValues({});

      final configNotifier = ConfigNotifier();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(configNotifier.dbUri, 'mongodb://env_host:27017/env_db');
    },
  );

  test(
    'ConfigNotifier prefers SharedPreferences over dotenv if stored',
    () async {
      dotenv.load(
        mergeWith: {'MONGODB_CONN_STR': 'mongodb://env_host:27017/env_db'},
      );
      SharedPreferences.setMockInitialValues({
        'config_db_uri': 'mongodb://custom_host:27017/test_db',
        'config_device_host': '192.168.1.50',
        'config_device_port': 4444,
      });

      final configNotifier = ConfigNotifier();
      // Allow async load to complete
      await Future.delayed(const Duration(milliseconds: 50));

      expect(configNotifier.dbUri, 'mongodb://custom_host:27017/test_db');
      expect(configNotifier.deviceHost, '192.168.1.50');
      expect(configNotifier.devicePort, 4444);

      await configNotifier.updateSettings(
        dbUri: 'mongodb://new_host:27017/another_db',
      );

      expect(configNotifier.dbUri, 'mongodb://new_host:27017/another_db');

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString('config_db_uri'),
        'mongodb://new_host:27017/another_db',
      );
    },
  );
}
