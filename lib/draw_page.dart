import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draw/draw_painter.dart';

class DrawPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  var _path = Path();
  var _color = Colors.red;
  var _lineWidth = 5.0;
  var _onEraseMode = false;
  Offset _currentOffset;
  final List<Line> _undoLines = [];
  final List<Line> _lines = [];

  void _goBack() {
    if (_lines.isNotEmpty) {
      setState(() {
        _undoLines.add(_lines.removeLast());
      });
    }
  }

  void _reset() {
    setState(() {
      _lines.clear();
      _undoLines.clear();
    });
  }

  void _forward() {
    if (_undoLines.isNotEmpty) {
      var last = _undoLines.last;
      _lines.add(last);
      _undoLines.removeLast();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            mini: true,
            child: Icon(
              Icons.style,
              color: _onEraseMode ? Colors.grey : Colors.white,
            ),
            onPressed: () {
              setState(() => _onEraseMode = !_onEraseMode);
            },
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            mini: true,
            child: Icon(Icons.arrow_back),
            onPressed: _goBack,
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            mini: true,
            child: Icon(Icons.replay),
            onPressed: _reset,
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            mini: true,
            child: Icon(Icons.arrow_forward_rounded),
            onPressed: _forward,
          ),
        ],
      ),
      body: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _undoLines.clear();
            _currentOffset = details.globalPosition;
            _path.moveTo(_currentOffset.dx, _currentOffset.dy);
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _currentOffset = details.globalPosition;
            _path.lineTo(_currentOffset.dx, _currentOffset.dy);
          });
        },
        onPanEnd: (details) {
          setState(() {
            _currentOffset = null;
            _lines.add(
              Line(
                path: Path.from(_path),
                color: _color,
                width: _lineWidth,
                eraseMode: _onEraseMode,
              ),
            );
            _path.reset();
          });
        },
        child: CustomPaint(
          size: Size.infinite,
          painter: DrawPainter(
            _lines,
            Line(
              path: Path.from(_path),
              color: _color,
              width: _lineWidth,
              eraseMode: _onEraseMode,
            ),
            currentOffset: _currentOffset,
          ),
        ),
      ),
    );
  }
}

class Line {
  Path path;
  Color color;
  double width;
  bool eraseMode;

  Line({this.path, this.color, this.width, this.eraseMode = false})
      : assert(path != null),
        assert(eraseMode != null);
}
