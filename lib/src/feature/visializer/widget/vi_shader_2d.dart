import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../controller/shader_2d_controller.dart';

/// {@template visualizer_screen}
/// ViShader2D widget.
/// {@endtemplate}
class ViShader2D extends StatefulWidget {
  /// {@macro visualizer_screen}
  const ViShader2D({
    required this.shader2D,
    required this.shader2dController,
    super.key, // ignore: unused_element
  });

  final ui.FragmentShader shader2D;
  final Shader2dController shader2dController;

  @override
  State<ViShader2D> createState() => _ViShader2DState();
}

/// State for widget ViShader2D.
class _ViShader2DState extends State<ViShader2D> {
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      size: Size.infinite,
      painter: ViShader2DPainter(shader: widget.shader2D, shader2dController: widget.shader2dController),
    ),
  );
}

class ViShader2DPainter extends CustomPainter {
  ViShader2DPainter({required this.shader, required this.shader2dController}) : super(repaint: shader2dController);

  final ui.FragmentShader shader;
  final Shader2dController shader2dController;

  static final paint1 = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.fill;

  static final barPaint = Paint()
    ..color = Colors.green
    ..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    // l.c(shader2dController.texture);

    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, shader2dController.time)
      ..setFloat(3, shader2dController.rmsAmplitude)
      ..setFloat(4, shader2dController.texture[0]);
    // ..setImageSampler(0, fftToImage(shader2dController.texture, width: size.width, height: size.height));

    final paint = Paint()..shader = shader;
    canvas
      ..save()
      ..drawRect(Offset.zero & size, paint)
      ..restore();
  }

  @override
  bool shouldRepaint(ViShader2DPainter oldDelegate) => false;
}
