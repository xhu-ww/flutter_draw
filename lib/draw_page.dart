import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draw/draw_painter.dart';

class DrawPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  List<Offset> offsets = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanStart: (details) {
          setState(() {
            offsets.add(details.globalPosition);
          });
        },
        onPanUpdate: (details) {
          setState(() {
            offsets.add(details.globalPosition);
          });
        },
        onPanEnd: (details) {
        },
        child: CustomPaint(
          size: Size.infinite,
          painter: DrawPainter(offsets),
        ),
      ),
    );
  }
}
