import 'package:flutter/material.dart';

class CustomSegmentedButton extends StatefulWidget {
  const CustomSegmentedButton({
    super.key,
    this.initialValue,
    required this.segments,
    required this.onChanged,
    required this.width,
    required this.height,
    this.multiSelect = false,
    this.selectedColor,
    this.unselectedColor,
  });

  final List<String> segments;
  final ValueChanged<dynamic> onChanged;
  final double width;
  final double height;
  final Color? selectedColor;
  final Color? unselectedColor;
  final dynamic initialValue;
  final bool multiSelect;

  @override
  State<CustomSegmentedButton> createState() => _CustomSegmentedButtonState();
}

class _CustomSegmentedButtonState extends State<CustomSegmentedButton> {
  late List<bool> _isSelected;

  @override
  void initState() {
    super.initState();
    if (widget.multiSelect) {
      if (widget.initialValue is List) {
        final selected = widget.initialValue as List;
        _isSelected = List.generate(
          widget.segments.length,
          (index) =>
              selected.contains(index) ||
              selected.contains(widget.segments[index]),
        );
      } else {
        _isSelected = List.filled(widget.segments.length, false);
      }
    } else {
      var selectedIndex = 0;
      if (widget.initialValue is int) {
        selectedIndex = widget.initialValue as int;
      } else if (widget.initialValue is String) {
        selectedIndex = widget.segments.indexOf(widget.initialValue as String);
        if (selectedIndex == -1) selectedIndex = 0;
      }
      _isSelected = List.generate(
        widget.segments.length,
        (index) => index == selectedIndex,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: _isSelected,
      onPressed: (value) {
        setState(() {
          if (widget.multiSelect) {
            _isSelected[value] = !_isSelected[value];
          } else {
            for (var i = 0; i < _isSelected.length; i++) {
              _isSelected[i] = i == value;
            }
          }
          if (widget.multiSelect) {
            final selectedIndices = <int>[];
            for (var i = 0; i < _isSelected.length; i++) {
              if (_isSelected[i]) selectedIndices.add(i);
            }
            widget.onChanged(selectedIndices);
          } else {
            widget.onChanged(value);
          }
        });
      },
      color: Theme.of(context).colorScheme.onSurface,
      selectedColor: Theme.of(context).colorScheme.onPrimary,
      fillColor: widget.selectedColor ?? Theme.of(context).colorScheme.primary,
      borderColor: Colors.grey,
      selectedBorderColor: Colors.grey,
      borderWidth: 1.0,
      borderRadius: BorderRadius.circular(8.0),
      children: widget.segments
          .map(
            (segment) => SizedBox(
              height: widget.height,
              width: (widget.width / widget.segments.length),
              child: Center(
                child: Text(
                  segment,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
