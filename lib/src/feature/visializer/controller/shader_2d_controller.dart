import 'dart:math' show sqrt;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logbook/logbook.dart';

/// {@template shader_2d_controller}
/// Shader2dController class
/// {@endtemplate}
class Shader2dController extends ChangeNotifier {
  /// {@macro shader_2d_controller}
  Shader2dController({required this.audioData});

  final AudioData audioData;

  double time = 0;
  Float32List texture = Float32List.fromList([]);
  double rmsAmplitude = 0;

  Future<void> update({required Duration elapsed}) async {
    final stopwatch = Stopwatch()..start();
    try {
      audioData.updateSamples();

      texture = audioData.getAudioData();

      rmsAmplitude = rmsAmplitudeFromFFT(texture);

      time = elapsed.inMilliseconds / 100.0;

      notifyListeners();
    } finally {
      l.f('Shader2dController update ${(stopwatch..stop()).elapsedMicroseconds} μs');
    }
  }

  double rmsAmplitudeFromFFT(List<double> fft) => sqrt(fft.map((e) => e * e).reduce((a, b) => a + b) / fft.length);
}
