import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yahp_director/providers/config/config_notifier.dart';
import 'package:yahp_director/providers/data/data_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'config_db_uri': 'mongodb://127.0.0.1:27017/test_db',
    });
  });

  test('DataProvider can be instantiated and disposed cleanly', () async {
    final config = ConfigNotifier();
    final dataProvider = DataProvider(config);

    expect(dataProvider.config, equals(config));

    // Calling dispose on an uninitialized/fresh DataProvider should complete without error
    await expectLater(dataProvider.dispose(), completes);
  });

  test(
    'DataProvider properly handles connection errors and cleans up resources',
    () async {
      final config = ConfigNotifier();
      // Using an invalid/unreachable host so connection fails
      await config.updateSettings(dbUri: 'mongodb://127.0.0.1:59999/test_db');

      final dataProvider = DataProvider(config);

      // Any DB operation should throw when connection fails, and cleanup resources without unhandled errors
      expect(() => dataProvider.getExperiments(), throwsA(anything));

      // After failure, dispose should still complete cleanly
      await expectLater(dataProvider.dispose(), completes);
    },
  );
}
