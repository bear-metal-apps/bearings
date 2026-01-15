
import 'package:flutter/material.dart';

// String textbox widget.
class StringTextbox extends StatefulWidget {
  final Color? fillColor;
  final Color? outlineColor;
  final String dataName;
  final Function(String) onChanged;
  final double xLength;
  final double yLength;

  const StringTextbox({
    super.key,
    this.fillColor,
    required this.onChanged,
    this.outlineColor,
    required this.dataName,
    required this.xLength,
    required this.yLength,
  });
  @override
  State<StringTextbox> createState() => _StringTextboxState();
}

class _StringTextboxState extends State<StringTextbox> {
 TextEditingController controller = TextEditingController();
  String value = '';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.xLength,
      height: widget.yLength,
      child: TextField(
        cursorColor: Colors.black,
        decoration: InputDecoration(
          filled: true,
          fillColor: widget.fillColor ?? Colors.white,
          labelText: widget.dataName,
          labelStyle: TextStyle(color: widget.outlineColor ?? Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: widget.outlineColor ?? Colors.black, width: 1.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: widget.outlineColor ?? Colors.red, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: widget.outlineColor ?? Colors.black, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: widget.outlineColor ?? Colors.black, width: 1.0),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
        controller: controller,
        onChanged: (text) {
          setState(() {
            value = controller.text;
            widget.onChanged(value);
          });
        },
      ),
    );
  }
}
