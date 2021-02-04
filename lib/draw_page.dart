import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draw/draw_painter.dart';

import 'widget/color_picker.dart';
import 'widget/draggable_align.dart';

class DrawPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  Path? _path;
  Color _color = Colors.lightGreen;
  var _lineWidth = 1.0;
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
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: (details) {
              var position = details.globalPosition;
              setState(() {
                _undoLines.clear();
                _currentOffset = position;
                _path = Path()..moveTo(position.dx, position.dy);
              });
            },
            onPanUpdate: (details) {
              var position = details.globalPosition;

              setState(() {
                _currentOffset = position;
                var dx = position.dx;
                var dy = position.dy;

                if (_previousOffset == null) {
                  _path?.lineTo(dx, dy);
                } else {
                  var previousDx = _previousOffset!.dx;
                  var previousDy = _previousOffset!.dy;

                  _path?.quadraticBezierTo(
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
                  Line(_path, _color, _lineWidth, eraseMode: _onEraseMode),
                );
                _path = null;
              });
            },
            child: CustomPaint(
              size: Size.infinite,
              painter: DrawPainter(
                _lines,
                Line(_path, _color, _lineWidth, eraseMode: _onEraseMode),
                currentOffset: _currentOffset,
              ),
            ),
          ),
          DraggableAlign(
            initialAlignment: Alignment(1, 0),
            child: Container(
              decoration: BoxDecoration(
                //背景颜色
                color: Color(0x60cccccc),
                //圆角半径
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
              ),
              margin: EdgeInsets.only(bottom: 18.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon(Icons.drag_indicator_outlined, color: _color),
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
                            setState(() => _lineWidth = v);
                          },
                        ),
                      ),
                      GestureDetector(
                        child: Icon(
                          Icons.color_lens_outlined,
                          color: _color,
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: ColorPicker(
                                  onColorChanged: (color) {
                                    setState(() => _color = color);
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(width: 24.0)
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFloatingActionButton(
                        Icon(
                          _onEraseMode
                              ? Icons.style
                              : Icons.drive_file_rename_outline,
                          color: _color,
                        ),
                        backgroundColor: _color,
                        onPressed: () {
                          setState(() => _onEraseMode = !_onEraseMode);
                        },
                      ),
                      _buildFloatingActionButton(
                        Icon(Icons.arrow_back, color: _color),
                        backgroundColor: _color,
                        onPressed: _goBack,
                      ),
                      _buildFloatingActionButton(
                        Icon(Icons.replay, color: _color),
                        backgroundColor: _color,
                        onPressed: _reset,
                      ),
                      _buildFloatingActionButton(
                        Icon(Icons.arrow_forward_rounded, color: _color),
                        backgroundColor: _color,
                        onPressed: _forward,
                      ),
                      _buildFloatingActionButton(
                        Icon(Icons.save_alt_outlined, color: _color),
                        backgroundColor: _color,
                        onPressed: _forward,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(
    Widget child, {
    Color? backgroundColor,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      child: Container(
        child: child,
        padding: EdgeInsets.symmetric(horizontal: 8),
      ),
      onTap: onPressed,
    );
  }
}

class Line {
  Path? path;
  Color color;
  double width;
  bool eraseMode;

  Line(this.path, this.color, this.width, {this.eraseMode = false});
}
