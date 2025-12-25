import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

class VisualizerController extends ChangeNotifier {
  VisualizerController({required this.audioData});

  final AudioData audioData;
  List<double> samples = [];

  void update() {
    audioData.updateSamples();
    samples = audioData.getAudioData();

    notifyListeners();
  }
}
