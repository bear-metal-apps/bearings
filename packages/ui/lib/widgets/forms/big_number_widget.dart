import 'package:flutter/material.dart';

class BigNumberWidget extends StatefulWidget {
  const BigNumberWidget({
    super.key,
    this.backgroundColor,
    required this.buttons,
    required this.width,
    required this.height,
    required this.dataName,
    this.initialValue,
    required this.onChanged,
  });

  final double width;
  final double height;
  final List<int> buttons;
  final Color? backgroundColor;
  final String dataName;
  final int? initialValue;
  final ValueChanged<int>? onChanged;

  @override
  State<BigNumberWidget> createState() => _BigNumberWidgetState();
}

class _BigNumberWidgetState extends State<BigNumberWidget> {
  late int _currentValue = widget.initialValue ?? 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final headerHeight = height * 0.28;
          final gridHeight = (height - headerHeight).clamp(0.0, height);
          final rows = (widget.buttons.length / 2).ceil().clamp(1, 4);
          final cellHeight = gridHeight / rows;
          final cellWidth = width / 2;
          final aspectRatio = cellHeight > 0 ? cellWidth / cellHeight : 1.0;

          return Column(
            children: [
              SizedBox(
                height: headerHeight,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${widget.dataName}: $_currentValue',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: gridHeight,
                width: width,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: widget.buttons.length,
                  itemBuilder: (context, index) {
                    final value = widget.buttons[index];
                    return ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentValue += value;
                          if (_currentValue <= 0) {
                            _currentValue = 0;
                          }
                        });
                        widget.onChanged?.call(_currentValue);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            widget.backgroundColor ??
                            Theme.of(context).colorScheme.surface,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: const BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Text(
                        value > 0 ? '+$value' : value.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
