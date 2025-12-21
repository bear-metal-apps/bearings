
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// String textbox widget.
class StringTextbox extends StatefulWidget {
  final Color? fillColor;
  final Color? outlineColor;
  final String dataName;
  final VoidCallback onChanged;
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

  static String get value => _StringTextboxState.value;

  @override
  State<StringTextbox> createState() => _StringTextboxState();
}

class _StringTextboxState extends State<StringTextbox> {
  static TextEditingController controller = TextEditingController();
  static late String value;
  @override
  void initState() {
    super.initState();
  }

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
            widget.onChanged();
          });
        },
      ),
    );
  }
}
