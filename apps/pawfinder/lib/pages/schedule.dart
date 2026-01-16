import 'dart:math';

import 'package:beariscope_scouter/custom_widgets/int_button.dart';
import 'package:beariscope_scouter/custom_widgets/tristate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return SchedulePageState();
  }
}

// DELETE BEFORE DEPLOYMENT
Map<String, dynamic> gameData = {'example': 67};

class SchedulePageState extends ConsumerState<SchedulePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'Schedule Page',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TristateButton(
            dataName: 'dataName',
            xLength: 300,
            yLength: 100,
            initialState: 0,
            onChanged: (int value) {
              // Handle the value change here
              print('TristateButton changed to state: $value');
            },
          ),
        ],
      ),
    );
  }
}
