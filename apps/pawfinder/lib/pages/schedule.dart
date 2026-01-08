import 'package:beariscope_scouter/custom_widgets/bool_button.dart';
import 'package:beariscope_scouter/custom_widgets/int_button.dart';
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

//example variable that the value of number button will be assigned to
int numericalButtonTestValue = 0;

//example variable that the value of tristate button will be assigned to
buttonState tristateButtonTestValue = buttonState.unchecked;

//example variable that the value of int textbox will be assigned to
int intTextboxTestValue = 0;

//example variable that the value of string textbox will be assigned to
String stringTextboxTestValue = '';

//etc. for other custom widgets
bool boolTextboxTestValue = false;

String selectedSegmentedButtonValue = 'Option 1';

String selectedDropdownValue = 'Option 1';

const List<String> stringDropdownOptions = <String>[
  'Option 1',
  'Option 2',
  'Option 3',
];

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
          NumberButton(
            dataName: 'Demo Button',
            backgroundColor: Colors.yellow,
            xLength: 300,
            yLength: 200,
            textAlignment: Alignment.bottomCenter,
            onChanged: () =>
                numericalButtonTestValue = NumberButton.currentVariable,
          ),
          // Example usage of TristateButton
          TristateButton(
            dataName: 'Demo Tristate',
            xLength: 100,
            yLength: 100,
            minfontSize: 20,
            onChanged: () => tristateButtonTestValue = currentState,
          ),
          // Example usage of IntTextbox
          IntTextbox(
            dataName: 'Demo Int Textbox',
            fillColor: Colors.red,
            outlineColor: Colors.black,
            xLength: 300,
            yLength: 100,
            onChanged: () => intTextboxTestValue = IntTextbox.value,
          ),
          StringTextbox(
            dataName: 'Demo String Textbox',
            fillColor: Colors.blue,
            outlineColor: Colors.black,
            xLength: 300,
            yLength: 100,
            onChanged: () => stringTextboxTestValue = StringTextbox.value,
          ),
          // Example usage of BoolButton
          BoolButton(
            dataName: 'Demo Bool Button',
            xLength: 200,
            yLength: 100,
            minfontSize: 20,
            onChanged: () => boolTextboxTestValue = BoolButton.value,
          ),
          Padding(padding:  EdgeInsets.all(20)),
          CustomSegmentedButton(
            segments: ['Option 1', 'Option 2', 'Option 3'],
            onChanged: (int newIndex) {
              setState(() {
                selectedSegmentedButtonValue = selectedSegment;
              });
            },
            selectedColor: Colors.blueGrey,
            xLength: 300,
            yLength: 100,
          ),
          Padding(padding:  EdgeInsets.all(20)),
          
          Dropdown(
            title: 'Dropdown Title',
            value: selectedDropdownValue,
            items: stringDropdownOptions,
            backgroundColor: Colors.white,
            xValue: 300,
            yValue: 100,
            uponChanged: (String? newValue) {
              setState(() {
                selectedDropdownValue = newValue!;
              });
            },
          ),
        ],
      ),
    );
  }
}
