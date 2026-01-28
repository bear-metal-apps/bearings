import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pressable_flutter/pressable_flutter.dart';

class BoolButton extends StatefulWidget {
  final String dataName;
  final double xLength;
  final double yLength;
  final Function(bool) onChanged;
  final double? minfontSize; // Optional font size parameter
  final bool visualFeedback;

  const BoolButton({
    super.key,
    this.minfontSize,
    required this.dataName,
    required this.xLength,
    required this.yLength,
    required this.onChanged,
    required this.visualFeedback,
  });

  @override
  _BoolButtonState createState() => _BoolButtonState();
}

class _BoolButtonState extends State<BoolButton> {
  bool boolButtonState = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.xLength,
      height: widget.yLength,
      child: Pressable(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            foregroundColor: Colors.black,
            backgroundColor: (boolButtonState == false)
                ? Colors.red
                : Colors.green,
            padding: EdgeInsets.all(16.0),
            minimumSize: Size(widget.xLength, widget.yLength),
          ),
          onPressed: () {
            setState(() {
              boolButtonState = !boolButtonState;
            });
            widget.onChanged(boolButtonState);
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
