import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class CustomSlider extends StatefulWidget {
  final String title;
  final double xValue;
  final double yValue;
  final int? segmentLength;
  final int minValue;
  final int maxValue;
  final Function(double) onChanged;

  const CustomSlider({
    required this.onChanged,
    required this.title,
    required this.xValue,
    required this.yValue,
    this.segmentLength,
    required this.minValue,
    required this.maxValue,
    super.key,
  });
  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  double sliderValue = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: widget.yValue,
          width: widget.xValue,
          child: SfSlider(
            min: widget.minValue.toDouble(),
            max: widget.maxValue.toDouble(),
            value: sliderValue,
            interval: (widget.segmentLength != null)
                ? widget.segmentLength!.toDouble()
                : null,
            showTicks: true,
            showLabels: true,
            enableTooltip: true,
            stepSize: (widget.segmentLength != null)
                ? widget.segmentLength!.toDouble()
                : null,
            onChanged: (value) {
              widget.onChanged?.call(value);
              setState(() {
                sliderValue = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
