import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../controller/shader_2d_controller.dart';

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
    if (shader2dController.image == null) return;

    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, shader2dController.time)
      ..setImageSampler(0, shader2dController.image!);

    final paint = Paint()..shader = shader;
    canvas
      ..save()
      ..drawRect(Offset.zero & size, paint)
      ..restore();
  }

  @override
  bool shouldRepaint(ViShader2DPainter oldDelegate) => false;
}
