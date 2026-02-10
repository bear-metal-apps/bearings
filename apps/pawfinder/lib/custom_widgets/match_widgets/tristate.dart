import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pressable_flutter/pressable_flutter.dart';

class TristateButton extends StatefulWidget {
  final String dataName;
  final double xLength;
  final double yLength;
  final Function(int) onChanged;
  final double? minfontSize; // Optional font size parameter
  final int? initialState;
  const TristateButton({
    super.key,
    this.initialState,
    this.minfontSize,
    required this.dataName,
    required this.xLength,
    required this.yLength,
    required this.onChanged,
  });

  @override
  _TristateState createState() => _TristateState();
}

class _TristateState extends State<TristateButton> {
  late int currentState =
      widget.initialState ?? 0; // 0: unchecked, 1: checked, 2: indeterminate
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.xLength,
      height: widget.yLength,
      child: Pressable(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            foregroundColor: Colors.black,
            backgroundColor: (currentState == 0
                ? Colors.red
                : currentState == 1
                ? Colors.green
                : currentState == 2
                ? Colors.yellow
                : Colors.grey),
          ),
          onPressed: () {
            setState(() {
              switch (currentState) {
                case 0:
                  currentState = 1;
                  break;
                case 1:
                  currentState = 2;
                  break;
                case 2:
                  currentState = 0;
                  break;
                default:
                  break;
              }
              widget.onChanged(currentState);
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
      ),
    );
  }
}
