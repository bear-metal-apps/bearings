import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

// Select between three states: checked, unchecked, indeterminate
enum buttonState { unchecked, checked, indeterminate }

class TristateButton extends StatefulWidget {
  final String dataName;
  final double xLength;
  final double yLength;
  final VoidCallback onChanged;
  final double? minfontSize; // Optional font size parameter

  const TristateButton({
    super.key,
    this.minfontSize,
    required this.dataName,
    required this.xLength,
    required this.yLength,
    required this.onChanged,
  });

  @override
  _TristateState createState() => _TristateState();
}

buttonState currentState = buttonState.unchecked;

class _TristateState extends State<TristateButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.xLength,
      height: widget.yLength,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          foregroundColor: Colors.black,
          backgroundColor: (currentState == buttonState.unchecked
              ? Colors.red
              : currentState == buttonState.checked
              ? Colors.green
              : currentState == buttonState.indeterminate
              ? Colors.yellow
              : Colors.grey),
        ),
        onPressed: () {
          setState(() {
            if (currentState == buttonState.unchecked) {
              currentState = buttonState.checked;
            } else if (currentState == buttonState.checked) {
              currentState = buttonState.indeterminate;
            } else if (currentState == buttonState.indeterminate) {
              currentState = buttonState.unchecked;
            }
            widget.onChanged();
          });
        },
        child: Center(
          child: AutoSizeText(
            widget.dataName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: widget.minfontSize ?? 20.0, // Use the provided font size or default to 16.0
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
