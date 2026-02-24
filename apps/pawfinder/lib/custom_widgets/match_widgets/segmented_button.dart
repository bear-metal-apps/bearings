import 'package:flutter/material.dart';

class CustomSegmentedButton extends StatefulWidget {
  final List<String> segments;
  final Function(int) onChanged;
  final double width;
  final double height;
  final Color? selectedColor;
  final Color? unselectedColor;
  final int? initialIndex;

  const CustomSegmentedButton({
    super.key,
    this.initialIndex,
    required this.segments,
    required this.onChanged,
    required this.width,
    required this.height,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.white,
  });

  @override
  State<CustomSegmentedButton> createState() => _CustomSegmentedButtonState();
}

class _CustomSegmentedButtonState extends State<CustomSegmentedButton> {
  String selectedSegment = '';
  late int selectedIndex = widget.initialIndex ?? 0;

  @override
  void initState() {
    super.initState();
    selectedSegment = widget.segments[selectedIndex];
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
          isSelected: List.generate(
            widget.segments.length,
            (index) => selectedSegment == widget.segments[index],
          ),
          onPressed: (value) {
            setState(() {
              selectedSegment = widget.segments[value];
              widget.onChanged(value);
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
                (segment) =>
                    SizedBox(
                        height: widget.height,
                        width: (widget.width/(widget.segments.length)),
                        child: Center(
                            child: Text(segment)
                        )
                    )
              )
              .toList(),
        );
      // ),
  }
}
