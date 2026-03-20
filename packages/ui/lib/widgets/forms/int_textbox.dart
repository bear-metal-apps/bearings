import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntTextbox extends StatefulWidget {
  const IntTextbox({
    super.key,
    this.initialValue,
    this.fillColor,
    required this.onChanged,
    this.outlineColor,
    required this.dataName,
    required this.width,
    required this.height,
  });

  final Color? fillColor;
  final Color? outlineColor;
  final String dataName;
  final ValueChanged<int> onChanged;
  final double width;
  final double height;
  final int? initialValue;

  @override
  State<IntTextbox> createState() => _IntTextboxState();
}

class _IntTextboxState extends State<IntTextbox> {
  final TextEditingController _controller = TextEditingController();
  late int _value = widget.initialValue ?? 0;

  @override
  void initState() {
    super.initState();
    _controller.text = _value.toString();
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
        cursorColor:
            widget.outlineColor ?? Theme.of(context).colorScheme.onSurface,
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
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (_) {
          setState(() {
            _value = int.tryParse(_controller.text) ?? 0;
            widget.onChanged(_value);
          });
        },
      ),
    );
  }
}
