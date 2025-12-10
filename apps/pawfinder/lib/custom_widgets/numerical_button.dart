import 'package:flutter/material.dart';

class NumberButton extends StatelessWidget {
  final int number;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Alignment textAlignment;
  final String dataName;
  final double xLength;
  final double yLength;

  const NumberButton({
    super.key,
    required this.number,
    required this.onPressed,
    required this.backgroundColor,
    required this.dataName,
    required this.xLength,
    required this.yLength,
    this.textAlignment = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: xLength,
      height: yLength,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
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
                '$dataName: $number',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Align(
              alignment: textAlignment,
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
                    // Action for the inner control
                    print('Inner control pressed!');
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
