import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logbook/logbook.dart';

import '../../feature/visualizer/screen/visualizer_screen.dart';

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
  Future<void> initializeSound() async {
    await SoLoud.instance.init(sampleRate: 44100, bufferSize: 1024, channels: Channels.mono);
    SoLoud.instance.setVisualizationEnabled(true);
  }

  @override
  void initState() {
    super.initState();

    initializeSound().ignore();
  }

  @override
  void dispose() {
    SoLoud.instance.deinit();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Voice Visualizer',
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
    home: const VisualizerScreen(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Logbook(child: child ?? const SizedBox.shrink()),
    ),
  );
}
