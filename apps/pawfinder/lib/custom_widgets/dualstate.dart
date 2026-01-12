import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Select between two states: checked, unchecked
enum dualButtonState { unchecked, checked }

class DualstateButton extends StatefulWidget {
  final String dataName;
  final double xLength;
  final double yLength;
  final VoidCallback onChanged;
  final double? minfontSize; // Optional font size parameter

  const DualstateButton({
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

dualButtonState dsCurrentState = dualButtonState.unchecked;

class _TristateState extends State<DualstateButton> {
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
          backgroundColor: (dsCurrentState == dualButtonState.unchecked
              ? Colors.red
              : dsCurrentState == dualButtonState.checked
              ? Colors.green
              : Colors.grey),
        ),
        onPressed: () {
          setState(() {
            if (dsCurrentState == dualButtonState.unchecked) {
              dsCurrentState = dualButtonState.checked;
            } else if (dsCurrentState == dualButtonState.checked) {
              dsCurrentState = dualButtonState.unchecked;
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
              fontSize:
                  widget.minfontSize ??
                  20.0, // Use the provided font size or default to 16.0
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
