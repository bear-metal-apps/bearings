import 'package:flutter/material.dart';
import 'package:pressable_flutter/pressable_flutter.dart';

// IMPORTANT: Font size automatically scales with screen size, but the text alignment and button size are fixed.
// Number button widget that adds and substracts a numerical value.
class BigNumberButton extends StatefulWidget {
  final Color? backgroundColor;
  final Alignment textAlignment;
  final String dataName;
  final Function(int)? onChanged;
  final double xLength;
  final double yLength;
  final bool? negativeAllowed;
  final int? initialValue;
  final int step;

  const BigNumberButton({
    super.key,
    this.initialValue,
    this.negativeAllowed = true,
    this.onChanged,
    this.backgroundColor,
    required this.dataName,
    required this.xLength,
    required this.yLength,
    this.textAlignment = Alignment.bottomRight,
    this.step = 1,
  });

  @override
  State<BigNumberButton> createState() => _BigNumberButtonState();
}

class _BigNumberButtonState extends State<BigNumberButton> {
  late int currentVariable = widget.initialValue ?? 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.xLength,
      height: widget.yLength,
      child: Pressable(
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentVariable += 5;
                });

                widget.onChanged?.call(currentVariable);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                    width: 2.0,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                    child: Text(
                      '${widget.dataName}: $currentVariable',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Align(
                    alignment: widget.textAlignment,
                    child: Container(
                      margin: const EdgeInsets.only(
                        right: 1.0,
                        left: 1.0,
                        bottom: 8.0,
                      ),
                      width: 56,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 24,
                        icon: Icon(Icons.remove, color: Theme.of(context).colorScheme.onSurface),
                        onPressed: () {
                          setState(() {
                            if (widget.negativeAllowed == true) {
                              currentVariable -= 5;
                            } else {
                              if (currentVariable > 0) {
                                currentVariable -= 5;
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
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentVariable += 10;
                });

                widget.onChanged?.call(currentVariable);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                    width: 2.0,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                    child: Text(
                      '${widget.dataName}: $currentVariable',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Align(
                    alignment: widget.textAlignment,
                    child: Container(
                      margin: const EdgeInsets.only(
                        right: 1.0,
                        left: 1.0,
                        bottom: 8.0,
                      ),
                      width: 56,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 24,
                        icon: Icon(Icons.remove, color: Theme.of(context).colorScheme.onSurface),
                        onPressed: () {
                          setState(() {
                            if (widget.negativeAllowed == true) {
                              currentVariable -= 10;
                            } else {
                              if (currentVariable > 0) {
                                currentVariable -= 10;
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
          ],
        ),
      ),
    );
  }
}
