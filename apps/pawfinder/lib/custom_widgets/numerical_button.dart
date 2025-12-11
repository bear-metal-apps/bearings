import 'package:flutter/material.dart';

// Number button widget that adds and substracts a numerical value.
class NumberButton extends StatefulWidget {
  final int variable;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Alignment textAlignment;
  final String dataName;
  final double xLength;
  final double yLength;

  const NumberButton({
    super.key,
    required this.variable,
    required this.onPressed,
    required this.backgroundColor,
    required this.dataName,
    required this.xLength,
    required this.yLength,
    this.textAlignment = Alignment.bottomRight,
  });

  @override
  State<NumberButton> createState() => _NumberButtonState();
}

class _NumberButtonState extends State<NumberButton> {
  late int currentVariable; // Mutable variable to track changes

  @override
  void initState() {
    super.initState();
    currentVariable = widget.variable; // Initialize with the passed value
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.xLength,
      height: widget.yLength,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            currentVariable++;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
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
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Align(
              alignment: widget.textAlignment,
              child: Container(
                margin: const EdgeInsets.only(right: 12.0, bottom: 8.0),
                width: 56,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 24,
                  icon: const Icon(Icons.remove, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      currentVariable--;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
