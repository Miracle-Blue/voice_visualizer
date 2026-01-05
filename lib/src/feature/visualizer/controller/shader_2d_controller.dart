import 'dart:async' show Completer;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logbook/logbook.dart';

import '../../../common/util/bmp_header.dart';

/// {@template shader_2d_controller}
/// Shader2dController class
/// {@endtemplate}
class Shader2dController extends ChangeNotifier {
  /// {@macro shader_2d_controller}
  Shader2dController({required this.audioData});

  final AudioData audioData;

  double time = 0;
  Float32List texture = Float32List.fromList([]);

  Duration lastUpdateTime = Duration.zero;

  ui.Image? image;

  Future<void> update({required Duration elapsed}) async {
    final stopwatch = Stopwatch()..start();
    try {
      audioData.updateSamples();

      texture = audioData.getAudioData();

      time = elapsed.inMilliseconds / 1000.0;

      if (elapsed.inMilliseconds - lastUpdateTime.inMilliseconds > 24) {
        buildImageForLinear(texture: texture).ignore();
        lastUpdateTime = elapsed;
      }

      notifyListeners();
    } finally {
      l.f('Shader2dController update ${(stopwatch..stop()).elapsedMicroseconds} μs');
    }
  }

  /* #region Constants */

  static const maxBinIndex = 255;
  static const minBinIndex = 0;
  static const cols = maxBinIndex - minBinIndex + 1;

  final linearData = Bmp32Header.setHeader(cols, 2);
  final img = Uint8List(cols * 2 * 4);

  /* #endregion */

  /// Create the texture to pass to the shader. The texture is a matrix of 256x2
  /// RGBA pixels representing:
  /// in the 1st row the frequencies data
  /// in the 2nd row the wave data
  Uint8List createBmpFromAudioData(Float32List texture) {
    for (var x = 0; x < cols; x++) {
      // fill FFT values
      final fft = (texture[x + minBinIndex].clamp(0.0, 1.0) * 255).toInt();
      img[x * 4] = fft; // R
      img[x * 4 + 1] = 0; // G
      img[x * 4 + 2] = 0; // B
      img[x * 4 + 3] = 255; // A

      // fill wave values
      final wave = (((texture[x + minBinIndex + 256].clamp(-1.0, 1.0) + 1.0) / 2.0) * 255).toInt();
      img[x * 4 + cols * 4] = wave;
      img[x * 4 + cols * 4 + 1] = 0; // G
      img[x * 4 + cols * 4 + 2] = 0; // B
      img[x * 4 + cols * 4 + 3] = 255; // A
    }
    return linearData.storeBitmap(img);
  }

  /// Build an image to be passed to the shader.
  /// The image is a matrix of 256x2 RGBA pixels representing:
  /// in the 1st row the frequencies data
  /// in the 2nd row the wave data
  Future<ui.Image?> buildImageForLinear({required Float32List texture}) async {
    final stopwatch = Stopwatch()..start();
    try {
      final completer = Completer<ui.Image>();
      final data = createBmpFromAudioData(texture);
      if (data.isEmpty) return null;

      ui.decodeImageFromList(data, completer.complete);

      /// Create the iChannel if not already
      final ret = await completer.future;
      return image = ret;
    } finally {
      l.f('Shader2dController buildImageForLinear ${(stopwatch..stop()).elapsedMilliseconds} ms');
    }
  }
}
