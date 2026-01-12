import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class Dropdown extends StatefulWidget {
  final String title;
  final String? value;
  final List<String> items;
  final Function(String?)? uponChanged;
  final double xValue;
  final double yValue;
  final Color backgroundColor;
  const Dropdown({
    required this.title,
    required this.backgroundColor,
    required this.value,
    required this.items,
    required this.xValue,
    required this.yValue,
    this.uponChanged,
    super.key,
  });

  @override
  State<Dropdown> createState() => _DropdownState();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _DropdownState extends State<Dropdown> {
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.value ?? widget.items.first;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.xValue,
      height: widget.yValue,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        color: widget.backgroundColor,
        child: DropdownButtonFormField<String>(
          borderRadius: BorderRadius.circular(10),
          initialValue: dropdownValue,
          isExpanded: true,
          dropdownColor: widget.backgroundColor,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            label: widget.title.isNotEmpty
                ? AutoSizeText(
                    widget.title,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    maxLines: 1,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: widget.items
              .map(
                (String value) =>
                    DropdownMenuItem<String>(value: value, child: Text(value)),
              )
              .toList(),
          onChanged: widget.uponChanged,
          hint: AutoSizeText(
            widget.title,
            style: TextStyle(fontSize: 16, color: Colors.black),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
