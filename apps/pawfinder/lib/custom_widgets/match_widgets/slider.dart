import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class CustomSlider extends StatefulWidget {
  final String title;
  final double width;
  final double height;
  final int? segmentLength;
  final int minValue;
  final int maxValue;
  final double? initialValue;
  final Function(double) onChanged;
  final bool isVertical;

  const CustomSlider({
    required this.onChanged,
    required this.title,
    required this.width,
    required this.height,
    this.segmentLength,
    required this.minValue,
    required this.maxValue,
    this.initialValue,
    this.isVertical = false,
    super.key,
  });
  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  late double sliderValue = widget.initialValue ?? 0;
  @override
  Widget build(BuildContext context) {
    if (widget.isVertical) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold)),
            SfSlider.vertical(
              min: widget.minValue.toDouble(),
              max: widget.maxValue.toDouble(),
              value: sliderValue,
              onChanged: (value) {
                widget.onChanged(value);
                setState(() => sliderValue = value);
              },
              interval: 1.0,
              showTicks: true,
              showLabels: true,
              // enableTooltip: true,
            ),
          ],
        ),
      );
    }
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold)),
          SfSlider(
            min: widget.minValue.toDouble(),
            max: widget.maxValue.toDouble(),
            value: sliderValue,
            onChanged: (value) {
              widget.onChanged(value);
              setState(() => sliderValue = value);
            },
            interval: 1.0,
            showTicks: true,
            showLabels: true,
            // enableTooltip: true,
          ),
        ],
      ),
    );
  }
}
