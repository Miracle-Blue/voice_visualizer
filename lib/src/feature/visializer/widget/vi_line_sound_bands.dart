import 'package:flutter/material.dart';

import '../controller/visualizer_controller.dart';

class ViLineSoundBands extends CustomPainter {
  ViLineSoundBands({required this.viController})
    : linePaint = Paint()..color = Colors.red,
      super(repaint: viController);

  final Paint linePaint;
  final VisualizerController viController;

  @override
  void paint(Canvas canvas, Size size) {
    if (viController.samples.isEmpty) return;

    const barWidth = 5.0;

    final fftData = viController.samples;

    final speechBands = [
      bandEnergy(fftData, 1, 3), // Low
      bandEnergy(fftData, 3, 12), // Low-Mid
      bandEnergy(fftData, 12, 32), // Mid
      bandEnergy(fftData, 32, 67), // High
    ];

    for (var i = -2; i < speechBands.length - 2; i++) {
      final barHeight = (speechBands[i + 2] * size.height).clamp(3.0, size.height);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width / 2 + (i * 1.5) * barWidth, (size.height - barHeight) / 2, barWidth, barHeight),
          const Radius.circular(50),
        ),
        linePaint,
      );
    }
  }

  double bandEnergy(List<double> fft, int start, int end) {
    double sum = 0;
    for (var i = start; i <= end; sum += fft[i++]) {}
    return sum / (end - start + 1);
  }

  @override
  bool shouldRepaint(ViLineSoundBands oldDelegate) => false;
}
