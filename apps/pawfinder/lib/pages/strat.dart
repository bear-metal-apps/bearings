import 'package:beariscope_scouter/custom_widgets/match_widgets/int_button.dart';
import 'package:beariscope_scouter/store/strat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../providers/scouting_providers.dart';

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

    final driverSkill = ref.watch(driverSkillProvider.notifier);
    final defensiveSkill = ref.watch(defensiveSkillProvider.notifier);
    final mechanicalStability = ref.watch(mechanicalStabilityProvider.notifier);
    final defensiveSusceptibility = ref.watch(mechanicalStabilityProvider.notifier);
    double defensiveSlider = 0.0;
    int humanPlayer = 0;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                SizedBox(width: size.width),

                createList("Driver Skill", driverSkill),
                createList("Defensive Susceptibility", defensiveSusceptibility),
                createList("Defensive Skill", defensiveSkill),
                SfSlider(
                  min: 0.0,
                  max: 10,
                  value: defensiveSlider,
                  onChanged: (value) {
                    setState(() => defensiveSlider = value
                    );
                  },
                  interval: 1.0,
                  showTicks: true,
                  showLabels: true,
                  // enableTooltip: true,
                ),
                createList("Mechanical Stability", mechanicalStability),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      humanPlayer++;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                      //   child:
                      Text(
                          'Human Player: $humanPlayer',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall
                      ),
                      // ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          width: 56,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.remove, color: Colors.black),
                            onPressed: () {
                              setState(() {
                                  if (humanPlayer > 0) {
                                    humanPlayer--;
                                  }
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ElevatedButton(
                onPressed: (){
                  ref.read(scoutingSessionProvider.notifier).nextMatch();
                },
                child: Text("Next Match")
            )
          ],
        ),
      ),
    );
  }
}
