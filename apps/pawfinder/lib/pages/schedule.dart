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

int testVar = 67;

class SchedulePageState extends ConsumerState<SchedulePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: NumberButton(
        dataName: 'Demo Button',
        variable: testVar,
        backgroundColor: Colors.purpleAccent,
        xLength: 300,
        yLength: 200,
        onPressed: () {},
      ),
    );
  }
}
