import 'package:flutter/material.dart';
import 'package:pressable_flutter/pressable_flutter.dart';

class NumberButton extends StatefulWidget {
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

  final Color? backgroundColor;
  final Alignment textAlignment;
  final String dataName;
  final ValueChanged<int>? onChanged;
  final double width;
  final double height;
  final bool? negativeAllowed;
  final int? initialValue;

  @override
  State<NumberButton> createState() => _NumberButtonState();
}

class _NumberButtonState extends State<NumberButton> {
  late int _currentVariable = widget.initialValue ?? 0;

  bool get _isNegativeAllowed => widget.negativeAllowed ?? true;

  @override
  void didUpdateWidget(covariant NumberButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _currentVariable = widget.initialValue ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Pressable(
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _currentVariable++;
            });

            widget.onChanged?.call(_currentVariable);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: const BorderSide(color: Colors.grey, width: 1.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${widget.dataName}: $_currentVariable',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Align(
                alignment: widget.textAlignment,
                child: Container(
                  width: 56,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: Colors.grey, width: 1.0),
                  ),
                  child: IconButton(
                    iconSize: 24,
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(56, 36),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.remove,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_isNegativeAllowed) {
                          _currentVariable--;
                        } else {
                          if (_currentVariable > 0) {
                            _currentVariable--;
                          }
                        }
                      });
                      widget.onChanged?.call(_currentVariable);
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
