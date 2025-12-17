
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Number button widget that adds and substracts a numerical value.
class IntTextbox extends StatefulWidget {
  final Color? backgroundColor;
  final String dataName;
  final VoidCallback onChanged;
  final double xLength;
  final double yLength;

  const IntTextbox({
    super.key,
    required this.onChanged,
    required this.backgroundColor,
    required this.dataName,
    required this.xLength,
    required this.yLength,
  });

  static int get value => _IntTextboxState.value;

  @override
  State<IntTextbox> createState() => _IntTextboxState();
}

class _IntTextboxState extends State<IntTextbox> {
  static TextEditingController controller = TextEditingController();
  static late int value;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.xLength,
      height: widget.yLength,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly
        ],
        onChanged: (text) {
          setState(() {
            value = int.tryParse(controller.text) ?? 0;
            widget.onChanged();
          });
        },
      ),
    );
  }
}
