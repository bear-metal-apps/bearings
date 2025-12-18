import 'package:beariscope_scouter/custom_widgets/numerical_button.dart';
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

//example variable that the value of int textbox will be assigned to
int intTextboxTestValue = 0;

class SchedulePageState extends ConsumerState<SchedulePage> {
  @override
  void dispose() {
    super.dispose();
<<<<<<< HEAD
=======
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
        IntTextbox(
          dataName: 'Demo Int Textbox',
          backgroundColor: Colors.orangeAccent,
          xLength: 300,
          yLength: 100,
          onChanged: () {
            intTextboxTestValue = IntTextbox.value;
            print(intTextboxTestValue);
          }, //replace intTextboxTestValue with desired variable
        ),
      ],
    );
>>>>>>> refs/remotes/origin/custom-widgets
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
        IntTextbox(
          dataName: 'Demo Int Textbox',
          backgroundColor: Colors.orangeAccent,
          xLength: 300,
          yLength: 100,
          onChanged: () {
            intTextboxTestValue = IntTextbox.value;
            print(intTextboxTestValue);
          }, //replace intTextboxTestValue with desired variable
        ),
      ],
    );
  }
}