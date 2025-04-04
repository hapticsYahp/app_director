import 'package:flutter/material.dart';
import '../components/home_page_tabs/user_tab.dart';
import '../components/home_page_tabs/experiments_tab.dart';
import '../components/home_page_tabs/settings_tab.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.sensors),
                text: 'Experiments',
              ),
              Tab(
                icon: Icon(Icons.assignment_ind),
                text: "User Data",
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
            ExperimentsTab(),
            UserTab(),
            SettingsTab(),
          ],
        ),
      ),
    );
  }
}
