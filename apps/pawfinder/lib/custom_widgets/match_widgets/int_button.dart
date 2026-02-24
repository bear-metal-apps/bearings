import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pressable_flutter/pressable_flutter.dart';

// IMPORTANT: Font size automatically scales with screen size, but the text alignment and button size are fixed.
// Number button widget that adds and substracts a numerical value.
class NumberButton extends StatefulWidget {
  final Color? backgroundColor;
  final Alignment textAlignment;
  final String dataName;
  final Function(int)? onChanged;
  final double width;
  final double height;
  final bool? negativeAllowed;
  final int? initialValue;

  const NumberButton({
    super.key,
    this.initialValue,
    this.negativeAllowed,
    this.onChanged,
    this.backgroundColor,
    required this.dataName,
    required this.width,
    required this.height,
    this.textAlignment = Alignment.bottomRight,
  });

  @override
  State<NumberButton> createState() => _NumberButtonState();
}

class _NumberButtonState extends State<NumberButton> {
  late int currentVariable = widget.initialValue ?? 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Pressable(
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              currentVariable++;
            });

            widget.onChanged?.call(currentVariable);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.backgroundColor ?? Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                Text(
                  '${widget.dataName}: $currentVariable',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall
                ),
              Align(
                alignment: widget.textAlignment,
                child: Container(
                  width: 56,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.remove, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        if (widget.negativeAllowed == null) {
                          widget.negativeAllowed == true;
                        }
                        if (widget.negativeAllowed == true) {
                          currentVariable--;
                        } else {
                          if (currentVariable > 0) {
                            currentVariable--;
                          }
                        }
                      });
                      widget.onChanged?.call(currentVariable);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
