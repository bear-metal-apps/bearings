import 'package:beariscope_scouter/custom_widgets/numerical_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return SchedulePageState();
  }
}

class SchedulePageState extends ConsumerState<SchedulePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: NumberButton(
        dataName: 'testButton',
        number: 67,
        backgroundColor: Colors.blue,
        xLength: 300,
        yLength: 200,
        onPressed: () {},
      ),
    );
  }
}
