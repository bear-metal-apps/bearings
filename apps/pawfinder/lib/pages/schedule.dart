import 'package:beariscope_scouter/custom_widgets/bool_button.dart';
import 'package:beariscope_scouter/custom_widgets/int_button.dart';
import 'package:beariscope_scouter/custom_widgets/slider.dart';
import 'package:beariscope_scouter/custom_widgets/text_box.dart';
import 'package:beariscope_scouter/custom_widgets/tristate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beariscope_scouter/custom_widgets/int_textbox.dart';
import 'package:beariscope_scouter/custom_widgets/dropdown.dart';
import 'package:beariscope_scouter/custom_widgets/segmented_button.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return SchedulePageState();
  }
}

// DELETE BEFORE DEPLOYMENT
Map<String, dynamic> gameData = {
  'numberButton1': 0,
  'numberButton2': 0,
  'intTextbox1': 0,
  'intTextbox2': 0,
  'stringTextbox1': '',
  'stringTextbox2': '',
  'selectedSegmentedButton1': '',
  'selectedSegmentedButton2': '',
  'selectedDropdown': '',
  'selectedDropdown2': '',
  'DropdownOptions': <String>[
    'Option 1',
    'Option 2',
    'Option 3',
    'Option 4',
    'Option 5',
  ],
  'SegmentedButtonOptions': <String>['Zayden', 'Ben', 'Jack', 'Aadi', 'Aarav'],
  'slider1': 0.0,
  'slider2': 0.0,
  'boolButton1': false,
  'boolButton2': false,
  'tristate2': buttonState.unchecked,
  'tristate1': buttonState.unchecked,
};

class SchedulePageState extends ConsumerState<SchedulePage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Example usage of NumberButton
          Text(
            'Schedule Page',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
