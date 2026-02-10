import 'package:flutter/material.dart';



class BigNumberWidget extends StatefulWidget {
  final double xLength;
  final double yLength;
  final List<int> buttons;
  final Color? backgroundColor;
  final String text;
  final int? initialValue;
  final Function(int)? onChanged;

  const BigNumberWidget({
    super.key,
    this.backgroundColor,
    required this.buttons,
    required this.xLength,
    required this.yLength,
    required this.text,
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
      width: widget.xLength,
      height: widget.yLength,
      child: Column(children: [
        Text(
          "${widget.text}: $currentValue",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black
          )
        ),
        SizedBox(
          width: widget.xLength,
          height: widget.yLength - 40,
          child: GridView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisExtent:(widget.xLength-40)/8 ),
            children: [
              for (final x in widget.buttons) 
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentValue += x;
                      });
                      widget.onChanged?.call(x);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.backgroundColor ?? Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(x > 0 ? "+$x" : x.toString()),
                  )

            ]
        )),
        
    ]));
  }
}