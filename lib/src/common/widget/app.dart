import 'package:flutter/material.dart';
import 'package:logbook/logbook.dart';

import '../../feature/home/screen/home_screen.dart';

/// {@template app}
/// App widget.
/// {@endtemplate}
class App extends StatefulWidget {
  /// {@macro app}
  const App({
    super.key, // ignore: unused_element
  });

  @override
  State<App> createState() => _AppState();
}

/// State for widget App.
class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Voice Visualizer',
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
    home: const HomeScreen(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Logbook(child: child!),
    ),
  );
}
