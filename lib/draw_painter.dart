import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DrawPainter extends CustomPainter {
  final List<Offset> points;

  DrawPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points == null) return;
    Paint paint = Paint()..color = Colors.red;
    for (Offset point in points) {
      canvas.drawCircle(point, 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
