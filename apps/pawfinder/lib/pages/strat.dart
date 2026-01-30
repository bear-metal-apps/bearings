import 'package:beariscope_scouter/store/strat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StratPage extends ConsumerStatefulWidget {
  const StratPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return StratPageState();
  }
}

class StratPageState extends ConsumerState<StratPage> {
  Column createList(String text, StratNotifier stratNotifier) {
    return Column(
      children: [
        Text(text, textScaler: TextScaler.linear(2)),

        SizedBox(
          width: 400,
          height: 160,
          child: ReorderableListView(
            onReorder: (int oldIndex, int newIndex) =>
                setState(() => stratNotifier.reorder(oldIndex, newIndex)),
            children: [
              for (final String item in stratNotifier.get())
                ListTile(
                  key: ValueKey(item),
                  title: Text(item),
                  trailing: const Icon(Icons.drag_handle),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    final driverSkill = ref.watch(driverSkillNotifierProvider.notifier);
    final rigidity = ref.watch(rigidityNotifierProvider.notifier);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                SizedBox(width: size.width),

                createList("Driver Skill", driverSkill),
                createList("Rigidity", rigidity),

                //createList("Rigidity", _rigidity),
                //createList("'i forgot' - Ben", _iForgot),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
