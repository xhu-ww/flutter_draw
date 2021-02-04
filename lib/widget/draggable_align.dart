import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DraggableAlign extends StatefulWidget {
  final Widget child;
  final Alignment initialAlignment;

  const DraggableAlign(
      {required this.child, this.initialAlignment = Alignment.center});

  @override
  State<StatefulWidget> createState() => _DraggableAlignState();
}

///TODO Modify location
class _DraggableAlignState extends State<DraggableAlign> {
  late Alignment _alignment;
  var _globalKey = GlobalKey();
  var _dragging = false;

  double _top = 0.0;
  double _left = 0.0;
  Offset? _offset;

  @override
  void initState() {
    super.initState();
    _alignment = widget.initialAlignment;
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      RenderObject? renderObject =
          _globalKey.currentContext?.findRenderObject();
      if (renderObject is RenderBox) {
        _offset = renderObject.localToGlobal(Offset.zero);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      key: _globalKey,
      top: _top,
      left: _left,
      child: Draggable(
        feedback: Material(
          color: Colors.transparent,
          child: widget.child,
        ),
        onDragStarted: () => setState(() => _dragging = true),
        onDragEnd: (details) {
          setState(() {
            _dragging = false;
            _top = details.offset.dy - _offset!.dy;
            _left = details.offset.dx - _offset!.dx;
          });
        },
        child: _dragging ? Container() : widget.child,
      ),
    );
  }
}
