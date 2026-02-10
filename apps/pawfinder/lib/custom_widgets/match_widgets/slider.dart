import 'package:flutter/material.dart';

class CustomSlider extends StatefulWidget {
  final String title;
  final double xValue;
  final double yValue;
  final int? segmentLength;
  final int minValue;
  final int maxValue;
  final double? initialValue;
  final Function(double) onChanged;

  const CustomSlider({
    required this.onChanged,
    required this.title,
    required this.xValue,
    required this.yValue,
    this.segmentLength,
    required this.minValue,
    required this.maxValue,
    this.initialValue,
    super.key,
  });
  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  late double sliderValue = widget.initialValue ?? 0;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.xValue,
      height: widget.yValue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Slider(
            min: widget.minValue.toDouble(),
            max: widget.maxValue.toDouble(),
            value: sliderValue,
            onChanged: (value) {
              widget.onChanged(value);
              setState(() => sliderValue = value);
            },
          ),
        ],
      ),
    );
  }
}
