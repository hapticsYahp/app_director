import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifi_app/providers/config/device_trial_notifier.dart';
import 'package:wifi_app/providers/data/data_provider.dart';
import '../components/home_page_tabs/user_device_tab.dart';
import '../components/home_page_tabs/experiments_tab.dart';
import '../components/home_page_tabs/settings_tab.dart';
import '../providers/config/config_notifier.dart';
import '../providers/config/subject_trial_notifier.dart';
import '../providers/poma/poma_client.dart';
import '../providers/poma/poma_socket_impl.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConfigNotifier>(
            create: (context) => ConfigNotifier()),
        ChangeNotifierProvider<DeviceTrialNotifier>(
            create: (_) => DeviceTrialNotifier()),
        ChangeNotifierProvider<SubjectTrialNotifier>(
            create: (_) => SubjectTrialNotifier()),
        Provider<PomaClient>(create: (context) => PomaClient(PomaSocketImpl())),
        ProxyProvider<ConfigNotifier, DataProvider>(
          update: (_, configNotifier, __) => DataProvider(configNotifier),
        ),
      ],
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.assignment_ind),
                  text: "Subject/Device",
                ),
                Tab(
                  icon: Icon(Icons.sensors),
                  text: 'Experiments',
                ),
                Tab(
                  icon: Icon(Icons.tune),
                  text: 'Settings',
                ),
              ],
            ),
            title: const Text('Haptic Interface'),
          ),
          body: const TabBarView(
            children: [
              UserDeviceTab(),
              ExperimentsTab(),
              SettingsTab(),
            ],
          ),
        ),
      ),
    );
  }
}
