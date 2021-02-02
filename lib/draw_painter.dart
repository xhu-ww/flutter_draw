import 'dart:ui';

import 'package:flutter/material.dart';

import 'draw_page.dart';

const ERASER_SIZE = 20.0;

class DrawPainter extends CustomPainter {
  final List<Line> lines;
  final Line currentLine;
  final Offset currentOffset;

  DrawPainter(this.lines, this.currentLine, {this.currentOffset})
      : assert(lines != null),
        assert(currentLine != null);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    for (Line line in lines) {
      _drawLine(canvas, line);
    }
    _drawLine(canvas, currentLine);
    canvas.restore();
    if (currentLine.eraseMode) {
      canvas.drawRect(
          Rect.fromCenter(
            center: currentOffset,
            width: ERASER_SIZE,
            height: ERASER_SIZE,
          ),
          Paint()..color = Colors.grey);
    }
  }

  void _drawLine(Canvas canvas, Line line) {
    canvas.drawPath(
      line.path,
      Paint()
        ..color = line.color ?? Colors.blue
        ..strokeWidth = line.eraseMode ? ERASER_SIZE : line.width ?? 5.0
        ..style = PaintingStyle.stroke
        ..blendMode = line.eraseMode ? BlendMode.clear : BlendMode.srcOver,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
