import 'package:flutter/material.dart';

/// width/height, The constraints for the widget in order to plug into the app (logic pixels)
///buttons, the possible buttons that can be used to change the widget value by the value
///backgroundColor, The background color, I know legitimately crazy
///dataName, The Title text given for the widget to label the value
///initialValue, the value it is initially saved as, important for match rotation
///onChanged, the lambda for the app to access the value of the widget
class BigNumberWidget extends StatefulWidget {
  final double width;
  final double height;
  final List<int> buttons;
  final Color? backgroundColor;
  final String dataName;
  final int? initialValue;
  final Function(int)? onChanged;

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

  @override
  State<BigNumberWidget> createState() => _BigNumberWidget();
}

class _BigNumberWidget extends State<BigNumberWidget> {
  late int currentValue = widget.initialValue ?? 0;

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
                      "${widget.dataName}: $currentValue",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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
                          currentValue += value;
                        });
                        widget.onChanged?.call(currentValue);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.backgroundColor ?? Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(value > 0 ? "+$value" : value.toString()),
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
