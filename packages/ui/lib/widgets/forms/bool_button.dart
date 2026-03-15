import 'package:flutter/material.dart';
import 'package:pressable_flutter/pressable_flutter.dart';

class BoolButton extends StatefulWidget {
  const BoolButton({
    super.key,
    this.initialValue,
    required this.dataName,
    required this.width,
    required this.height,
    required this.onChanged,
    required this.visualFeedback,
  });

  final String dataName;
  final double width;
  final double height;
  final ValueChanged<bool> onChanged;
  final bool visualFeedback;
  final bool? initialValue;

  @override
  State<BoolButton> createState() => _BoolButtonState();
}

class _BoolButtonState extends State<BoolButton> {
  late bool _boolButtonState = widget.initialValue ?? false;

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
              side: const BorderSide(color: Colors.grey, width: 1.0),
            ),
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            backgroundColor: _boolButtonState ? Colors.green : Colors.red,
            padding: const EdgeInsets.all(16.0),
            minimumSize: Size(widget.width, widget.height),
          ),
          onPressed: () {
            setState(() {
              _boolButtonState = !_boolButtonState;
            });
            widget.onChanged(_boolButtonState);
          },
          child: Center(
            child: Text(
              widget.dataName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
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
