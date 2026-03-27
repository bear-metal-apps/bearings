import 'package:flutter/material.dart';
import 'package:pressable_flutter/pressable_flutter.dart';

class NumberButton extends StatefulWidget {
  const NumberButton({
    super.key,
    this.initialValue,
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
  final int? initialValue;

  @override
  State<NumberButton> createState() => _NumberButtonState();
}

class _NumberButtonState extends State<NumberButton> {
  late int _currentVariable = widget.initialValue ?? 0;

  @override
  void didUpdateWidget(covariant NumberButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _currentVariable = widget.initialValue ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Pressable(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: (widget.backgroundColor ?? scheme.surface).withValues(
              alpha: 0.66,
            ),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: scheme.outlineVariant, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _currentVariable++;
              });

              widget.onChanged?.call(_currentVariable);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              foregroundColor: scheme.onSecondaryContainer,
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
                  '${widget.dataName}: $_currentVariable',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: scheme.onSecondaryContainer,
                  ),
                ),
                Align(
                  alignment: widget.textAlignment,
                  child: Container(
                    width: 56,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scheme.surface.withValues(alpha: 0.86),
                          scheme.surfaceContainerHighest.withValues(alpha: 0.88),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: scheme.outlineVariant, width: 1.0),
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
                        color: scheme.onSurface,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_currentVariable > 0) {
                            _currentVariable--;
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
      ),
    );
  }
}
