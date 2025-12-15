import 'package:flutter/material.dart';
import 'package:yahp_director/pages/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  ThemeData get theme => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      );

  HomePage get home => HomePage();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haptic Interface',
      theme: theme,
      home: home,
    );
  }
}
