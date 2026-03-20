import 'package:flutter/material.dart';

class StringTextbox extends StatefulWidget {
  const StringTextbox({
    super.key,
    this.fillColor,
    required this.onChanged,
    this.outlineColor,
    required this.dataName,
    required this.width,
    required this.height,
    this.initialString,
  });

  final Color? fillColor;
  final Color? outlineColor;
  final String dataName;
  final ValueChanged<String> onChanged;
  final double width;
  final double height;
  final String? initialString;

  @override
  State<StringTextbox> createState() => _StringTextboxState();
}

class _StringTextboxState extends State<StringTextbox> {
  final TextEditingController _controller = TextEditingController();
  late String _value = widget.initialString ?? '';

  @override
  void initState() {
    super.initState();
    _controller.text = _value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TextField(
        cursorColor: Theme.of(context).colorScheme.onSurface,
        decoration: InputDecoration(
          filled: true,
          fillColor: widget.fillColor ?? Theme.of(context).colorScheme.surface,
          labelText: widget.dataName,
          labelStyle: TextStyle(
            color:
                widget.outlineColor ?? Theme.of(context).colorScheme.onSurface,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color:
                  widget.outlineColor ?? Theme.of(context).colorScheme.outline,
              width: 2.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: widget.outlineColor ?? Colors.red,
              width: 2.0,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color:
                  widget.outlineColor ??
                  Theme.of(context).colorScheme.onSurface,
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color:
                  widget.outlineColor ?? Theme.of(context).colorScheme.primary,
              width: 2.0,
            ),
          ),
        ),
        controller: _controller,
        onChanged: (_) {
          setState(() {
            _value = _controller.text;
            widget.onChanged(_value);
          });
        },
      ),
    );
  }
}
