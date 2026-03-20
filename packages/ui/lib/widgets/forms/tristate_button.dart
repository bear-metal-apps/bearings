import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pressable_flutter/pressable_flutter.dart';

class TristateButton extends StatefulWidget {
  const TristateButton({
    super.key,
    this.initialValue,
    required this.dataName,
    required this.width,
    required this.height,
    required this.onChanged,
  });

  final String dataName;
  final double width;
  final double height;
  final ValueChanged<int> onChanged;
  final int? initialValue;

  @override
  State<TristateButton> createState() => _TristateButtonState();
}

class _TristateButtonState extends State<TristateButton> {
  late int _currentState = widget.initialValue ?? 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Pressable(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: const BorderSide(color: Colors.grey, width: 1.0),
            ),
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            backgroundColor: _currentState == 0
                ? Colors.red
                : _currentState == 1
                ? Colors.green
                : _currentState == 2
                ? Colors.yellow
                : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              switch (_currentState) {
                case 0:
                  _currentState = 1;
                  break;
                case 1:
                  _currentState = 2;
                  break;
                case 2:
                  _currentState = 0;
                  break;
              }
              widget.onChanged(_currentState);
            });
          },
          child: Center(
            child: AutoSizeText(
              widget.dataName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
