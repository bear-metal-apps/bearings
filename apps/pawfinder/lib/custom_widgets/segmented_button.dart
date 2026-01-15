import 'package:flutter/material.dart';
import 'package:pressable_flutter/pressable_flutter.dart';

class CustomSegmentedButton extends StatefulWidget {
  final List<String> segments;
  final Function(int) onChanged;
  final double xLength;
  final double yLength;
  final Color? selectedColor;
  final Color? unselectedColor;

  const CustomSegmentedButton({
    super.key,
    required this.segments,
    required this.onChanged,
    required this.xLength,
    required this.yLength,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.white,
  });

  @override
  State<CustomSegmentedButton> createState() => _CustomSegmentedButtonState();
}

class _CustomSegmentedButtonState extends State<CustomSegmentedButton> {
  String selectedSegment = '';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.xLength,
      height: widget.yLength,
      child: Pressable(
        child: ToggleButtons(
          isSelected: List.generate(
            widget.segments.length,
            (index) => selectedSegment == widget.segments[index],
          ),
          onPressed: (value) {
            selectedSegment = widget.segments[value];
            widget.onChanged(value);
          },
          color: Colors.black,
          selectedColor: Colors.white,
          fillColor: widget.selectedColor,
          borderColor: Colors.grey,
          selectedBorderColor: Colors.grey,
          borderRadius: BorderRadius.circular(8.0),
          children: widget.segments
              .map(
                (segment) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(segment),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
