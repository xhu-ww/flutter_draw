import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draw/draw_painter.dart';

import 'color_picker.dart';

class DrawPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  var _path = Path();
  var _color = Color(0xFF2196F3);
  var _lineWidth = 5.0;
  var _onEraseMode = false;
  Offset? _previousOffset;
  Offset? _currentOffset;
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
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
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: (details) {
              var position = details.globalPosition;
              setState(() {
                _undoLines.clear();
                _currentOffset = position;
                _path.moveTo(position.dx, position.dy);
              });
            },
            onPanUpdate: (details) {
              var position = details.globalPosition;

              setState(() {
                _currentOffset = position;
                var dx = position.dx;
                var dy = position.dy;

                if (_previousOffset == null) {
                  _path.lineTo(dx, dy);
                } else {
                  var previousDx = _previousOffset!.dx;
                  var previousDy = _previousOffset!.dy;

                  _path.quadraticBezierTo(
                    previousDx,
                    previousDy,
                    (previousDx + dx) / 2,
                    (previousDy + dy) / 2,
                  );
                }
                _previousOffset = position;
              });
            },
            onPanEnd: (details) {
              setState(() {
                _currentOffset = null;
                _previousOffset = null;

                _lines.add(
                  Line(Path.from(_path), _color, _lineWidth,
                      eraseMode: _onEraseMode),
                );
                _path.reset();
              });
            },
            child: CustomPaint(
              size: Size.infinite,
              painter: DrawPainter(
                _lines,
                Line(
                  Path.from(_path),
                  _color,
                  _lineWidth,
                  eraseMode: _onEraseMode,
                ),
                currentOffset: _currentOffset,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 32.0,
              width: 240.0,
              decoration: BoxDecoration(
                //背景颜色
                color: Color(0x60cccccc),
                //圆角半径
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
              ),
              margin: EdgeInsets.only(bottom: 18.0),
              alignment: Alignment.center,
              child: Row(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        activeTrackColor: _color,
                        thumbColor: _color,
                        valueIndicatorColor: _color,
                        activeTickMarkColor: Colors.transparent,
                        inactiveTrackColor: _color.withAlpha(100),
                        inactiveTickMarkColor: Colors.transparent,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 6),
                        showValueIndicator: ShowValueIndicator.always),
                    child: Slider(
                      value: _lineWidth,
                      min: 0,
                      max: 10,
                      divisions: 20,
                      label: _lineWidth.toString(),
                      onChanged: (v) {
                        setState(() {
                          _lineWidth = v;
                        });
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Container(
                              width: 150,
                              height: 300,
                              child: ColorPicker(
                                onColorChanged: (color) {
                                  setState(() => _color = color);
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey, width: 0.5),
                      ),
                      padding: EdgeInsets.all(3.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _color,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Line {
  Path path;
  Color color;
  double width;
  bool eraseMode;

  Line(this.path, this.color, this.width, {this.eraseMode = false});
}
