import 'package:beariscope_scouter/custom_widgets/numerical_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return SchedulePageState();
  }
}
//example variable that the value of number button will be assigned to
int testValue = 0;


class SchedulePageState extends ConsumerState<SchedulePage> {
  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      // Example usage of NumberButton
      child: NumberButton(
        dataName: 'Demo Button',
        backgroundColor: Colors.purpleAccent,
        xLength: 300,
        yLength: 200,
        textAlignment: Alignment.center,
        onPressed: () => testValue = NumberButton.currentVariable, //replace testValue with desired variable
      ),
    );
  }
}

