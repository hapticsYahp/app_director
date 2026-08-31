import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yahp_director/providers/config/device_trial_notifier.dart';
import 'package:yahp_director/providers/data/data_provider.dart';
import '../components/home_page_tabs/user_device_tab.dart';
import '../components/home_page_tabs/experiments_tab.dart';
import '../components/home_page_tabs/settings_tab.dart';
import '../providers/config/config_notifier.dart';
import '../providers/config/subject_trial_notifier.dart';
import '../providers/poma/poma_client.dart';
import '../providers/poma/transport/ble_poma_transport.dart';
import '../providers/poma/transport/tcp_poma_transport.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConfigNotifier>(
          create: (context) => ConfigNotifier(),
        ),
        ChangeNotifierProvider<DeviceTrialNotifier>(
          create: (_) => DeviceTrialNotifier(),
        ),
        ChangeNotifierProvider<SubjectTrialNotifier>(
          create: (_) => SubjectTrialNotifier(),
        ),
        Provider<PomaClient>(
          create: (context) {
            final configNotifier = Provider.of<ConfigNotifier>(
              context,
              listen: false,
            );
            final transport =
                configNotifier.connectionType == ConnectionType.ble
                ? BlePomaTransport(
                    deviceId: configNotifier.deviceMac,
                    timeout: Duration(
                      seconds: configNotifier.deviceConnectionTimeout,
                    ),
                  )
                : TcpPomaTransport(
                    host: configNotifier.deviceHost,
                    port: configNotifier.devicePort,
                    timeout: Duration(
                      seconds: configNotifier.deviceConnectionTimeout,
                    ),
                  );
            return PomaClient(transport);
          },
          dispose: (_, client) => client.dispose(),
        ),
        ProxyProvider<ConfigNotifier, DataProvider>(
          update: (_, configNotifier, previous) =>
              previous ?? DataProvider(configNotifier),
          dispose: (_, dataProvider) => dataProvider.dispose(),
        ),
      ],
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.assignment_ind), text: "Subject/Device"),
                Tab(icon: Icon(Icons.sensors), text: 'Experiments'),
                Tab(icon: Icon(Icons.tune), text: 'Settings'),
              ],
            ),
            title: const Text('Haptic Interface'),
          ),
          body: const TabBarView(
            children: [UserDeviceTab(), ExperimentsTab(), SettingsTab()],
          ),
        ),
      ),
    );
  }
}
