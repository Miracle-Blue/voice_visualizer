import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logbook/logbook.dart';

class VisualizerController extends ChangeNotifier {
  VisualizerController({required this.audioData});

  final AudioData audioData;
  List<double> samples = [];

  void update() {
    final stopwatch = Stopwatch()..start();
    try {
      audioData.updateSamples();
      samples = audioData.getAudioData();

      notifyListeners();
    } finally {
      l.f('VisualizerController update ${(stopwatch..stop()).elapsedMicroseconds} μs');
    }
  }
}
