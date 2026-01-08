import 'package:flutter/material.dart';

class CustomSegmentedButton extends StatefulWidget {
  final List<String> segments;
  final ValueChanged<int> onChanged;
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
String selectedSegment = '';
class _CustomSegmentedButtonState extends State<CustomSegmentedButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.xLength,
      height: widget.yLength,
      child: ToggleButtons(
        isSelected: List.generate(
          widget.segments.length,
          (index) => selectedSegment == widget.segments[index],
        ),
        onPressed: (index) {
          selectedSegment = widget.segments[index];
          widget.onChanged(index);
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
    );
  }
}
