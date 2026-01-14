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
          NumberButton(
            dataName: 'Demo Button',
            backgroundColor: Colors.yellow,
            xLength: 300,
            yLength: 200,
            textAlignment: Alignment.bottomCenter,
            onChanged: (value) {
              gameData['numberButton'] = value;
              print(gameData['numberButton']);
            },
          ),
          // Example usage of TristateButton
          TristateButton(
            dataName: 'Demo Tristate',
            xLength: 100,
            yLength: 100,
            minfontSize: 20,
            onChanged: (value) {
              gameData['tristate1'] = value;
              print(gameData['tristate1']);
            },
          ),
          // Example usage of IntTextbox
          IntTextbox(
            dataName: 'Demo Int Textbox',
            fillColor: Colors.red,
            outlineColor: Colors.black,
            xLength: 300,
            yLength: 100,
            onChanged: (value) {
              gameData['intTextbox1'] = value;
              print(gameData['intTextbox1']);
            },
          ),
          StringTextbox(
            dataName: 'Demo String Textbox',
            fillColor: Colors.blue,
            outlineColor: Colors.black,
            xLength: 300,
            yLength: 100,
            onChanged: (value) {
              gameData['stringTextbox1'] = value;
              print(gameData['stringTextbox1']);
            },
          ),
          // Example usage of BoolButton
          BoolButton(
            dataName: 'Demo Bool Button',
            xLength: 200,
            yLength: 100,
            minfontSize: 20,
            onChanged: (bool value) {
              gameData['boolButton1'] = value;
              print(gameData['boolButton1']);
            },
            visualFeedback: true,
          ),
          Padding(padding: EdgeInsets.all(20)),
          CustomSegmentedButton(
            segments: gameData['SegmentedButtonOptions'],
            onChanged: (int newIndex) {
              setState(() {
                gameData['selectedSegmentedButton1'] =
                    gameData['SegmentedButtonOptions'][newIndex];
                print(gameData['selectedSegmentedButton1']);
              });
            },
            selectedColor: Colors.blueGrey,
            xLength: 300,
            yLength: 100,
          ),
          Padding(padding: EdgeInsets.all(20)),

          Dropdown(
            title: 'Dropdown Title',

            items: gameData['DropdownOptions'],
            backgroundColor: Colors.white,
            xValue: 300,
            yValue: 100,
            uponChanged: (String? newValue) {
              setState(() {
                gameData['selectedDropdown1'] = newValue!;
                print(gameData['selectedDropdown1']);
              });
            },
          ),

          NumberButton(
            dataName: 'Demo Button',
            backgroundColor: Colors.yellow,
            xLength: 300,
            yLength: 200,
            textAlignment: Alignment.bottomCenter,
            onChanged: (value) {
              gameData['numberButton2'] = value;
              print(gameData['numberButton2']);
            },
          ),
          // Example usage of TristateButton
          TristateButton(
            dataName: 'Demo Tristate',
            xLength: 100,
            yLength: 100,
            minfontSize: 20,
            onChanged: (value) {
              gameData['tristate2'] = value;
              print(gameData['tristate2']);
            },
          ),
          // Example usage of IntTextbox
          IntTextbox(
            dataName: 'Demo Int Textbox',
            fillColor: Colors.red,
            outlineColor: Colors.black,
            xLength: 300,
            yLength: 100,
            // ignore: avoid_types_as_parameter_names
            onChanged: (int) {
              gameData['intTextbox2'] = int;
              print(gameData['intTextbox2']);
            },
          ),
          StringTextbox(
            dataName: 'Demo String Textbox',
            fillColor: Colors.blue,
            outlineColor: Colors.black,
            xLength: 300,
            yLength: 100,
            onChanged: (value) {
              gameData['stringTextbox2'] = value;
              print(gameData['stringTextbox2']);
            },
          ),
          // Example usage of BoolButton
          BoolButton(
            dataName: 'Demo Bool Button',
            xLength: 200,
            yLength: 100,
            minfontSize: 20,
            onChanged: (value) {
              gameData['boolButton2'] = value;
              print(gameData['boolButton2']);
            },
            visualFeedback: true,
          ),
          Padding(padding: EdgeInsets.all(20)),
          CustomSegmentedButton(
            segments: gameData['SegmentedButtonOptions'],
            onChanged: (int newIndex) {
              setState(() {
                gameData['selectedSegmentedButton2'] =
                    gameData['SegmentedButtonOptions'][newIndex];
                print(gameData['selectedSegmentedButton2']);
              });
            },
            selectedColor: Colors.blueGrey,
            xLength: 300,
            yLength: 100,
          ),
          Padding(padding: EdgeInsets.all(20)),
          CustomSlider(
            title: 'Demo Slider',
            xValue: 300,
            yValue: 100,
            minValue: 0,
            maxValue: 100,
            segmentLength: 10,
            onChanged: (value) {
              gameData['slider1'] = value;
              print(gameData['slider1']);
            },
          ),
          CustomSlider(
            title: 'Demo Slider',
            xValue: 300,
            yValue: 100,
            minValue: 0,
            maxValue: 50,
            onChanged: (value) {
              gameData['slider2'] = value;
              print(gameData['slider2']);
            },
          ),
          Dropdown(
            title: 'Dropdown Title',

            items: gameData['DropdownOptions'],
            backgroundColor: Colors.white,
            xValue: 300,
            yValue: 100,
            uponChanged: (String? newValue) {
              setState(() {
                gameData['selectedDropdown2'] = newValue;
                print(gameData['selectedDropdown2']);
              });
            },
          ),
        ],
      ),
    );
  }
}
