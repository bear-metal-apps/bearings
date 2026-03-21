import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pressable_flutter/pressable_flutter.dart';

class Dropdown extends StatefulWidget {
  const Dropdown({
    super.key,
    this.initialIndex,
    required this.title,
    required this.backgroundColor,
    required this.items,
    required this.width,
    required this.height,
    this.onChanged,
  });

  final String title;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final double width;
  final double height;
  final Color backgroundColor;
  final int? initialIndex;

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  late String _dropdownValue;

  @override
  void initState() {
    super.initState();
    _dropdownValue = widget.items.first;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Pressable(
        child: DropdownButtonFormField<String>(
          borderRadius: BorderRadius.circular(10),
          initialValue: widget.initialIndex != null
              ? widget.items[widget.initialIndex!]
              : _dropdownValue,
          isExpanded: true,
          dropdownColor: widget.backgroundColor,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            label: widget.title.isNotEmpty
                ? Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          items: widget.items
              .map(
                (value) =>
                    DropdownMenuItem<String>(value: value, child: Text(value)),
              )
              .toList(),
          onChanged: widget.onChanged,
          hint: AutoSizeText(
            widget.title,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
