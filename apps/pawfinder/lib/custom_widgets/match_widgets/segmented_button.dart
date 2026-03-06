import 'package:flutter/material.dart';

class CustomSegmentedButton extends StatefulWidget {
  final List<String> segments;
  final Function(dynamic) onChanged;
  final double width;
  final double height;
  final Color? selectedColor;
  final Color? unselectedColor;
  final dynamic initialValue;
  final bool multiSelect;

  const CustomSegmentedButton({
    super.key,
    this.initialValue,
    required this.segments,
    required this.onChanged,
    required this.width,
    required this.height,
    this.multiSelect = false,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.white,
  });

  @override
  State<CustomSegmentedButton> createState() => _CustomSegmentedButtonState();
}

class _CustomSegmentedButtonState extends State<CustomSegmentedButton> {
  late List<bool> isSelected;

  @override
  void initState() {
    super.initState();
    if (widget.multiSelect) {
      if (widget.initialValue is List) {
        final selected = widget.initialValue as List;
        isSelected = List.generate(
          widget.segments.length,
          (index) => selected.contains(index) || selected.contains(widget.segments[index]),
        );
      } else {
        isSelected = List.filled(widget.segments.length, false);
      }
    } else {
      int selectedIndex = 0;
      if (widget.initialValue is int) {
        selectedIndex = widget.initialValue;
      } else if (widget.initialValue is String) {
        selectedIndex = widget.segments.indexOf(widget.initialValue);
        if (selectedIndex == -1) selectedIndex = 0;
      }
      isSelected = List.generate(
        widget.segments.length,
        (index) => index == selectedIndex,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: isSelected,
      onPressed: (value) {
        setState(() {
          if (widget.multiSelect) {
            isSelected[value] = !isSelected[value];
          } else {
            for (int i = 0; i < isSelected.length; i++) {
              isSelected[i] = i == value;
            }
          }
          if (widget.multiSelect) {
            final selectedIndices = <int>[];
            for (int i = 0; i < isSelected.length; i++) {
              if (isSelected[i]) selectedIndices.add(i);
            }
            widget.onChanged(selectedIndices);
          } else {
            widget.onChanged(value);
          }
        });
      },
      color: Colors.black,
      selectedColor: Colors.white,
      fillColor: widget.selectedColor,
      borderColor: Colors.grey,
      selectedBorderColor: Colors.grey,
      borderRadius: BorderRadius.circular(8.0),
      children: widget.segments
          .map(
            (segment) => SizedBox(
              height: widget.height,
              width: (widget.width / (widget.segments.length)),
              child: Center(child: Text(segment)),
            ),
          )
          .toList(),
    );
  }
}
