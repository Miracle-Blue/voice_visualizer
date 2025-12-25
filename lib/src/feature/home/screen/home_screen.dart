import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logbook/logbook.dart';

/// {@template home_screen}
/// HomeScreen widget.
/// {@endtemplate}
class HomeScreen extends StatefulWidget {
  /// {@macro home_screen}
  const HomeScreen({
    super.key, // ignore: unused_element
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State for widget HomeScreen.
class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  SoLoud? soLoud;
  AudioData? audioData;

  Ticker? ticker;

  SoundHandle? soundHandle;
  AudioSource? audioSource;

  late VisualizerController visualizerController;

  Future<void> playSound() async {
    audioSource ??= await soLoud?.loadAsset('assets/music/skyfall.mp3');
    soundHandle ??= await soLoud?.play(audioSource!);

    soLoud?.setFftSmoothing(.7);

    ticker ??= Ticker((_) => visualizerController.update())..start().ignore();
  }

  Future<void> stopSound() async {
    await soLoud?.stop(soundHandle!);
    soundHandle = null;

    ticker?.stop();
    ticker?.dispose();
    ticker = null;
  }

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();

    visualizerController = VisualizerController(audioData: AudioData(GetSamplesKind.linear));

    soLoud = SoLoud.instance;
  }

  @override
  void dispose() {
    ticker?.stop();
    ticker?.dispose();
    ticker = null;

    soLoud?.deinit();

    visualizerController.dispose();

    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Home')),
    body: RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: 100,
              child: Center(
                child: CustomPaint(
                  painter: VisualizerPainter(visualizerController: visualizerController),
                  size: const Size(double.infinity, 80),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 100,
              child: Center(
                child: CustomPaint(
                  painter: VisualizerLine(visualizerController: visualizerController),
                  size: const Size(double.infinity, 80),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    floatingActionButton: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        FloatingActionButton(onPressed: playSound, child: const Icon(Icons.play_arrow)),
        FloatingActionButton(onPressed: stopSound, child: const Icon(Icons.stop)),
      ],
    ),
  );
}

class VisualizerPainter extends CustomPainter {
  VisualizerPainter({required this.visualizerController})
    : barPaint = Paint()..color = Colors.lightBlueAccent,
      super(repaint: visualizerController);

  final Paint barPaint;
  final VisualizerController visualizerController;

  @override
  void paint(Canvas canvas, Size size) {
    l.c('paint: ${visualizerController.samples.length}');
    if (visualizerController.samples.isEmpty) return;

    // We're only interested in FFT data (first 256 values)
    final fftData = visualizerController.samples.sublist(0, 256);
    final barWidth = size.width / fftData.length;

    for (var i = 0; i < fftData.length; i++) {
      // FFT data typically contains values between 0.0 and 1.0
      final barHeight = fftData[i] * size.height;

      canvas.drawRect(
        Rect.fromLTWH(
          i * barWidth, // Left position
          size.height - barHeight, // Top position (from bottom)
          barWidth, // Width of each bar
          barHeight, // Height of each bar
        ),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(VisualizerPainter oldDelegate) =>
      oldDelegate.visualizerController.samples.length != visualizerController.samples.length;
}

class VisualizerLine extends CustomPainter {
  VisualizerLine({required this.visualizerController})
    : linePaint = Paint()..color = Colors.red,
      super(repaint: visualizerController);

  final Paint linePaint;
  final VisualizerController visualizerController;

  @override
  void paint(Canvas canvas, Size size) {
    if (visualizerController.samples.isEmpty) return;

    const barWidth = 10.0;

    final fftData = visualizerController.samples;

    final speechBands = [
      bandEnergy(fftData, 1, 2), // Low / pitch
      bandEnergy(fftData, 2, 6), // Vowels
      bandEnergy(fftData, 6, 17), // Clarity
      bandEnergy(fftData, 17, 46), // Presence
    ];

    for (var i = 0; i < speechBands.length; i++) {
      final barHeight = (speechBands[i] * size.height).clamp(0.0, size.height);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * barWidth, size.height - barHeight, barWidth, barHeight),
          const Radius.circular(50),
        ),
        linePaint,
      );
    }
  }

  double bandEnergy(List<double> fft, int start, int end) {
    double sum = 0;
    for (var i = start; i <= end; i++) {
      sum += fft[i];
    }
    return sum / (end - start + 1);
  }

  @override
  bool shouldRepaint(VisualizerLine oldDelegate) =>
      oldDelegate.visualizerController.samples.length != visualizerController.samples.length;
}

class VisualizerController extends ChangeNotifier {
  VisualizerController({required this.audioData});

  AudioData audioData;

  List<double> samples = [];

  void update() {
    audioData.updateSamples();
    samples = audioData.getAudioData();

    notifyListeners();
  }
}
