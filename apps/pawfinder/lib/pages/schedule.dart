import 'package:beariscope_scouter/custom_widgets/bool_button.dart';
import 'package:beariscope_scouter/custom_widgets/int_button.dart';
import 'package:beariscope_scouter/custom_widgets/text_box.dart';
import 'package:beariscope_scouter/custom_widgets/tristate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beariscope_scouter/custom_widgets/int_textbox.dart';

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

class SchedulePageState extends ConsumerState<SchedulePage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          xLength: 300,
          yLength: 100,
          onChanged: () => boolTextboxTestValue = BoolButton.value,
        ),
      ],
    );
  }
}
