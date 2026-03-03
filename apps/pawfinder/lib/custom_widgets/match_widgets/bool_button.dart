import 'package:flutter/material.dart';
import 'package:pressable_flutter/pressable_flutter.dart';

class BoolButton extends StatefulWidget {
  final String dataName;
  final double width;
  final double height;
  final Function(bool) onChanged;
  final bool visualFeedback;
  final bool? initialValue;

  const BoolButton({
    super.key,
    this.initialValue,
    required this.dataName,
    required this.width,
    required this.height,
    required this.onChanged,
    required this.visualFeedback,
  });

  @override
  _BoolButtonState createState() => _BoolButtonState();
}

class _BoolButtonState extends State<BoolButton> {
  late bool boolButtonState = widget.initialValue ?? false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Pressable(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 2.0,
              ),
            ),
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            backgroundColor: (boolButtonState == false)
                ? Colors.red
                : Colors.green,
            padding: EdgeInsets.all(16.0),
            minimumSize: Size(widget.width, widget.height),
          ),
          onPressed: () {
            setState(() {
              boolButtonState = !boolButtonState;
            });
            widget.onChanged(boolButtonState);
          },
          child: Center(
            child: Text(
              widget.dataName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
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
