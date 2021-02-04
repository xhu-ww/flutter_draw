import 'dart:ui';

import 'package:flutter/material.dart';

import 'draw_page.dart';

const ERASER_SIZE = 20.0;

class DrawPainter extends CustomPainter {
  final List<Line> lines;
  final Line currentLine;
  final Offset? currentOffset;

  DrawPainter(this.lines, this.currentLine, {this.currentOffset});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    for (Line line in lines) {

      _drawLine(canvas, line);
    }
    _drawLine(canvas, currentLine);
    canvas.restore();
    if (currentLine.eraseMode && currentOffset != null) {
      canvas.drawRect(
          Rect.fromCenter(
            center: currentOffset!,
            width: ERASER_SIZE,
            height: ERASER_SIZE,
          ),
          Paint()..color = Colors.grey);
    }
  }

  void _drawLine(Canvas canvas, Line line) {
    var path = line.path;
    if (path == null) return;
    canvas.drawPath(
      path,
      Paint()
        ..color = line.color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = line.eraseMode ? ERASER_SIZE : line.width
        ..isAntiAlias = true
        ..blendMode = line.eraseMode ? BlendMode.clear : BlendMode.srcOver,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
