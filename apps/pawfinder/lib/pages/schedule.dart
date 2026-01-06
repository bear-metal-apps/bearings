import 'package:beariscope_scouter/custom_widgets/dualstate.dart';
import 'package:beariscope_scouter/custom_widgets/int_button.dart';
import 'package:beariscope_scouter/custom_widgets/text_box.dart';
import 'package:beariscope_scouter/custom_widgets/tristate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beariscope_scouter/custom_widgets/int_textbox.dart';
import 'package:beariscope_scouter/custom_widgets/dropdown.dart';
import 'package:beariscope_scouter/custom_widgets/slider.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return SchedulePageState();
  }
}
//im going to change this someday to use a map and providers but for now this is fine
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

String selectedDropdownValue = 'Option 1';

const List<String> stringDropdownOptions = <String>[
  'Option 1',
  'Option 2',
  'Option 3',
];

int currentSliderValue = 0;

bool demoDualButtonState = false;

class SchedulePageState extends ConsumerState<SchedulePage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Page')),
      body: SingleChildScrollView(
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
            Dropdown(
              title: 'Demo Dropdown',
              value: selectedDropdownValue,
              items: stringDropdownOptions,
              backgroundColor: Colors.white,
              xValue: 300,
              yValue: 100,
              uponChanged: (String? newValue) {
                selectedDropdownValue = newValue!;
              },
            ),
            CustomSlider(
              title: 'Demo Slider',
              xValue: 300,
              yValue: 50,
              minValue: 0,
              maxValue: 100,
              segmentLength: 20,
              onChanged: (double newValue) {
                currentSliderValue = newValue.toInt();
              },
            ),
            DualstateButton(
              dataName: 'Demo Dualstate',
              xLength: 150,
              yLength: 100,
              minfontSize: 16,
              onChanged: () {
                demoDualButtonState =
                    (dsCurrentState == dualButtonState.checked);
              },
            ),],
        ),
      ),
    );
  }
}
