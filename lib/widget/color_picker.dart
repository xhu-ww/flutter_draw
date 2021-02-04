import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ColorPicker extends StatefulWidget {
  final ValueChanged<Color>? onColorChanged;

  const ColorPicker({Key? key, this.onColorChanged}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 300,
      child: GridView.count(
        primary: false,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        crossAxisCount: 4,
        children: Colors.primaries
            .map((e) => _buildColorItem(e, () {
                  Navigator.of(context).pop();
                  widget.onColorChanged?.call(e);
                }))
            .toList(),
      ),
    );
  }

  Widget _buildColorItem(Color color, GestureTapCallback onSelect) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
