import 'package:flutter/material.dart';
import 'package:pressable_flutter/pressable_flutter.dart';

///width/height, The constraints for the widget in order to plug into the app (logic pixels)
///backgroundColors, The possible background colors,
///text, The Title text given for the widget to label the value
///initialValue, the value it is initially saved as, important for match rotation
///onChanged, the lambda for the app to access the value of the widget
///
class TristateButton extends StatefulWidget {
  final String dataName;
  final double width;
  final double height;
  final Function(int) onChanged;
  // final double? minfontSize; // Optional font size parameter
  final int? initialValue;

  const TristateButton({
    super.key,
    this.initialValue,
    // this.minfontSize,
    required this.dataName,
    required this.width,
    required this.height,
    required this.onChanged,
  });

  @override
  _TristateState createState() => _TristateState();
}

class _TristateState extends State<TristateButton> {
  late int currentState =
      widget.initialValue ?? 0; // 0: unchecked, 1: checked, 2: indeterminate
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
              side: BorderSide(
                color: Colors.white,
                width: 1.0,
              ),
            ),
            foregroundColor: Theme.of(context).colorScheme.onSurface,
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
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            ),
          ),
        ),
      ),
    );
  }
}
