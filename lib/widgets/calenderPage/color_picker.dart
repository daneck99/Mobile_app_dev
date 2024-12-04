import 'package:flutter/material.dart';

class ColorPicker extends StatelessWidget {
  final Function(Color) onColorSelected;
  final Color selectedColor;

  const ColorPicker({super.key, required this.onColorSelected, required this.selectedColor});

  Widget renderColor(Color color, bool isSelected) {
    return GestureDetector(
      onTap: () => onColorSelected(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
            ? Border.all(
            color: Colors.black,
            width: 3
          ):null
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      runAlignment: WrapAlignment.start,
      children: [
        renderColor(Colors.pinkAccent, selectedColor==Colors.pinkAccent),
        renderColor(Colors.yellowAccent.shade200, selectedColor==Colors.yellowAccent.shade200),
        renderColor(Colors.blue, selectedColor==Colors.blue),
      ],
    );
  }
}
