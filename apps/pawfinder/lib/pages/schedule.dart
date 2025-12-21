import 'package:beariscope_scouter/custom_widgets/numerical_button.dart';
import 'package:beariscope_scouter/custom_widgets/tristate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beariscope_scouter/custom_widgets/int_textbox.dart';


//asdklfnldsjfljasdd
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
          backgroundColor: Colors.purpleAccent,
          xLength: 300,
          yLength: 200,
          textAlignment: Alignment.center,
          onPressed: () {
            numericalButtonTestValue = NumberButton.currentVariable;
            print(
              numericalButtonTestValue,
            ); //replace numericalButtonTestValue with desired variable
          },
        ),
        // Example usage of TristateButton
        TristateButton(
          dataName: 'Demo Tristate',
          xLength: 100,
          yLength: 100,
          stateChanged: () {
            tristateButtonTestValue = currentState;
            print(  tristateButtonTestValue,  ); //replace tristateButtonTestValue with desired variable
          },
        ),
        // Example usage of IntTextbox
        IntTextbox(
          dataName: 'Demo Int Textbox',
          backgroundColor: Colors.orangeAccent,
          xLength: 300,
          yLength: 100,
          onChanged: () {
            intTextboxTestValue = IntTextbox.value;
          }, //replace intTextboxTestValue with desired variable
        ),
      ],
    );
  }
}
