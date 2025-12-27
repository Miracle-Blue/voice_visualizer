import 'package:flutter/material.dart';

import '../controller/visualizer_controller.dart';

class ViSpectrum extends CustomPainter {
  ViSpectrum({required this.viController})
    : barPaint = Paint()..color = Colors.lightBlueAccent,
      super(repaint: viController);

  final Paint barPaint;
  final VisualizerController viController;

  @override
  void paint(Canvas canvas, Size size) {
    if (viController.samples.isEmpty) return;

    // We're only interested in FFT data (first 256 values)
    final fftData = viController.samples.sublist(0, 256);
    final barWidth = size.width / fftData.length;

    for (var i = 0; i < fftData.length; i++) {
      // FFT data typically contains values between 0.0 and 1.0
      final barHeight = (fftData[i] * size.height).clamp(.5, size.height);

      canvas
        ..save()
        ..drawRect(
          .fromLTWH(
            i * barWidth, // Left position
            size.height - barHeight, // Top position (from bottom)
            barWidth, // Width of each bar
            barHeight, // Height of each bar
          ),
          barPaint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(ViSpectrum oldDelegate) => false;
}
