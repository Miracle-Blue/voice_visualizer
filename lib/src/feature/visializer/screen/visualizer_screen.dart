import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import '../controller/visualizer_controller.dart';
import '../widget/vi_line_sound_bands.dart';
import '../widget/vi_spectrum.dart';

part '../state/visualizer_screen_state.dart';

/// {@template visualizer_screen}
/// VisualizerScreen widget.
/// {@endtemplate}
class VisualizerScreen extends StatefulWidget {
  /// {@macro visualizer_screen}
  const VisualizerScreen({
    super.key, // ignore: unused_element
  });

  @override
  State<VisualizerScreen> createState() => _VisualizerScreenState();
}

/// State for widget VisualizerScreen.
class _VisualizerScreenState extends VisualizerScreenState {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Visualizer')),
    body: Padding(
      padding: const .all(16),
      child: Column(
        spacing: 12,
        mainAxisSize: .min,
        crossAxisAlignment: .center,
        children: [
          SizedBox(
            width: .infinity,
            height: 100,
            child: CustomPaint(painter: ViSpectrum(viController: viController)),
          ),

          SizedBox(
            width: .infinity,
            height: 50,
            child: CustomPaint(painter: ViLineSoundBands(viController: viController)),
          ),
        ],
      ),
    ),
    floatingActionButton: Row(
      spacing: 12,
      mainAxisSize: .min,
      children: [
        FloatingActionButton(onPressed: playSound, child: const Icon(Icons.play_arrow)),
        FloatingActionButton(onPressed: stopSound, child: const Icon(Icons.stop)),
      ],
    ),
  );
}
