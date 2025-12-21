import 'package:flutter/material.dart';
// text scaling handled with FittedBox; no external package required

//Select between three states: checked, unchecked, indeterminate
enum buttonState { unchecked, checked, indeterminate }

class TristateButton extends StatefulWidget {
  final String dataName;
  final double xLength;
  final double yLength;
  final VoidCallback stateChanged;

  const TristateButton({
    super.key,
    required this.dataName,
    required this.xLength,
    required this.yLength,
    required this.stateChanged,
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
            widget.stateChanged();
          });
        },
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.dataName,
              style: const TextStyle(color: Colors.black, fontSize: 20),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
