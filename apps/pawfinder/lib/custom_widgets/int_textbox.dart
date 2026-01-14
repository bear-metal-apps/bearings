import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Number button widget that adds and substracts a numerical value.
class IntTextbox extends StatefulWidget {
  final Color? fillColor;
  final Color? outlineColor;
  final String dataName;
  final Function(int) onChanged;
  final double xLength;
  final double yLength;

  const IntTextbox({
    super.key,
    this.fillColor,
    required this.onChanged,
    this.outlineColor,
    required this.dataName,
    required this.xLength,
    required this.yLength,
  });

  @override
  State<IntTextbox> createState() => _IntTextboxState();
}

class _IntTextboxState extends State<IntTextbox> {
  TextEditingController controller = TextEditingController();
  int value = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.xLength,
      height: widget.yLength,
      child: TextField(
        cursorColor: widget.outlineColor ?? Colors.black,
        decoration: InputDecoration(
          filled: true,
          fillColor: widget.fillColor ?? Colors.white,
          labelText: widget.dataName,
          labelStyle: TextStyle(color: widget.outlineColor ?? Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: widget.outlineColor ?? Colors.black,
              width: 1.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: widget.outlineColor ?? Colors.red,
              width: 1.0,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: widget.outlineColor ?? Colors.black,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: widget.outlineColor ?? Colors.black,
              width: 1.0,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (text) {
          setState(() {
            value = int.tryParse(controller.text) ?? 0;
            widget.onChanged(value);
          });
        },
      ),
    );
  }
}
