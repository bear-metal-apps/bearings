import 'dart:convert';

import 'package:beariscope_scouter/custom_widgets/match_widgets/2026_specifc/big_number.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/bool_button.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/dropdown.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/int_button.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/int_textbox.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/segmented_button.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/slider.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/text_box.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/tristate.dart';
import 'package:beariscope_scouter/data/local_data.dart';
import 'package:beariscope_scouter/models/scouting_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';

import '../data/ui_json_serialization.dart';
import '../providers/scouting_providers.dart';

Box dataBox = Hive.box(boxKey);

Future<Map<String, dynamic>> loadUiConfig() async {
  final jsonString = await rootBundle.loadString('resources/ui_creator.json');
  return jsonDecode(jsonString);
}

// MatchIdentity currentMatchIdentity = (eventKey: "eventKey", matchNumber: 0, isRedAlliance: false, position: 0, robotNum: 0);
// class matchPagesProvider extends ChangeNotifier {
//
// }
final matchPagesProvider =
    AsyncNotifierProvider<MatchPagesNotifier, List<List<Widget>>>(
      MatchPagesNotifier.new,
    );

class MatchPagesNotifier extends AsyncNotifier<List<List<Widget>>> {
  String _buildDataKey(String fieldId) {
    final session = ref.read(scoutingSessionProvider);
    final eventKey = session.event?.key ?? 'unknown_event';
    final matchNumber = session.matchNumber?.toString() ?? 'unknown_match';
    final positionKey = session.position?.name ?? 'unknown_position';
    return 'MATCH_${eventKey}_${matchNumber}_${positionKey}_$fieldId';
  }

  @override
  Future<List<List<Widget>>> build() async {
    // Provider starts empty until load() is called
    return [];
  }

  Future<void> loadUI(BuildContext context) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final mediaQuery = MediaQuery.of(context);
      final ultimateHeight = mediaQuery.size.height;
      final ultimateWidth = mediaQuery.size.width;

      final json = jsonDecode(
        await rootBundle.loadString('resources/ui_creator.json'),
      );

      final pages = MatchConfig.fromJson(json).pages;
      final List<List<Widget>> matchPages = [];

      for (int index = 0; index < pages.length; index++) {
        matchPages.add([]);

        final page = pages[index];
        final horizontalStep = ultimateWidth / page.width;
        final verticalStep = (ultimateHeight - 130) / page.height;

        for (final data in page.components) {
          final dataBoxKey = _buildDataKey(data.fieldId);
          final storedValue = dataBox.get(dataBoxKey);

          Widget widget;
          switch (data.type) {
            case 'volumetric_button':
              widget = BigNumberWidget(
                key: ValueKey(dataBoxKey),
                buttons: [
                  1, 5, -1, -5,
                ],
                xLength: data.layout.w * horizontalStep,
                yLength: data.layout.h * verticalStep,
                text: data.alias,
                initialValue: storedValue is int ? storedValue : null,
                onChanged: (value) => dataBox.put(dataBoxKey, value),
              );
              break;
            case "int_button":
              widget = NumberButton(
                key: ValueKey(dataBoxKey),
                backgroundColor: Colors.white,
                dataName: data.alias,
                xLength: data.layout.w * horizontalStep,
                yLength: data.layout.h * verticalStep,
                initialValue: storedValue is int ? storedValue : null,
                onChanged: (value) => dataBox.put(dataBoxKey, value),
              );
              break;
            case "int_text_box":
              widget = IntTextbox(
                key: ValueKey(dataBoxKey),
                onChanged: (value) => dataBox.put(dataBoxKey, value),
                dataName: data.alias,
                xLength: data.layout.w * horizontalStep,
                yLength: data.layout.h * verticalStep,
                initialValue: storedValue is int ? storedValue : null,
              );
              break;
            case "toggle_switch":
              widget = BoolButton(
                key: ValueKey(dataBoxKey),
                dataName: data.alias,
                xLength: data.layout.w * horizontalStep,
                yLength: data.layout.h * verticalStep,
                initialValue: storedValue is bool ? storedValue : null,
                onChanged: (value) => dataBox.put(dataBoxKey, value),
                visualFeedback: true,
              );
              break;

            case "text_box":
              widget = StringTextbox(
                key: ValueKey(dataBoxKey),
                dataName: data.alias,
                xLength: data.layout.w * horizontalStep,
                yLength: data.layout.h * verticalStep,
                initialString: storedValue is String ? storedValue : null,
                onChanged: (value) => dataBox.put(dataBoxKey, value),
              );
              break;

            case "dropdown":
            List<dynamic> items = data.parameters["options"];
            int initialIndex = items.indexOf(storedValue);

              widget = Dropdown(
                key: ValueKey(dataBoxKey),
                title: data.alias,
                backgroundColor: Colors.blueAccent,
                items: items.map((x) => x.toString()).toList(), // darts type system is really weird
                onChanged: (value) => dataBox.put(dataBoxKey, value),
                initialIndex: initialIndex == -1 ? null : initialIndex,
                xValue: data.layout.w * horizontalStep,
                yValue: data.layout.h * verticalStep,
              );
              break;
            case "tristate":
              widget = TristateButton(
                key: ValueKey(dataBoxKey),
                dataName: data.alias,
                xLength: data.layout.w * horizontalStep,
                yLength: data.layout.h * verticalStep,
                initialState: storedValue is int ? storedValue : null,
                onChanged: (value) => dataBox.put(dataBoxKey, value),
              );
              break;
            case "checkbox":
              widget = BoolButton(
                key: ValueKey(dataBoxKey),
                dataName: data.alias,
                xLength: data.layout.w * horizontalStep,
                yLength: data.layout.h * verticalStep,
                visualFeedback: true,
                initialValue: storedValue is bool ? storedValue : null,
                onChanged: (value) => dataBox.put(dataBoxKey, value),
              );
              break;
            case "slider":
              final double? sliderValue =
                  storedValue is num ? storedValue.toDouble() : null;
              widget = CustomSlider(
                key: ValueKey(dataBoxKey),
                onChanged: (value) => dataBox.put(dataBoxKey, value),
                title: data.alias,
                xValue: data.layout.w * horizontalStep,
                yValue: data.layout.h * verticalStep,
                minValue: 0,
                maxValue: 10,
                initialValue: sliderValue,
              );
              break;
            case "segmented_button":
              List<dynamic> items = data.parameters["options"];
              int? initialIndex;
              if (storedValue is int) {
                initialIndex = storedValue >= 0 && storedValue < items.length
                    ? storedValue
                    : null;
              } else if (storedValue is String) {
                final idx = items.indexOf(storedValue);
                initialIndex = idx >= 0 ? idx : null;
              }
              widget = CustomSegmentedButton(
                  key: ValueKey(dataBoxKey),
                  segments: items.map((x) => x.toString()).toList(),
                  onChanged: (value) => dataBox.put(dataBoxKey, value),
                  initialIndex: initialIndex,
                  xLength: data.layout.w * horizontalStep,
                  yLength: data.layout.h * verticalStep
              );
              break;
            case "Nxt":
              widget = SizedBox(
                  height: data.layout.h * verticalStep,
                  width: data.layout.w * horizontalStep,
                  child: Builder(
                    builder: (ctx) => ElevatedButton(
                      onPressed: (){
                        ref.read(scoutingSessionProvider.notifier).nextMatch();
                        ctx.go('/match/auto');
                      },
                      child: Text("Next Match")
                    )
                  )
              );
              break;
            default:
              continue;
          }
          matchPages[index].add(
            Positioned(
              top: data.layout.y * verticalStep,
              left: data.layout.x * horizontalStep,
              child: widget,
            ),
          );
        }
      }
      return matchPages;
    });
  }
}

class MatchPage extends ConsumerStatefulWidget {
  final index;

  const MatchPage({super.key, required this.index});

  @override
  ConsumerState<MatchPage> createState() => MatchPageState();
}

class MatchPageState extends ConsumerState<MatchPage> {
  @override
  Widget build(BuildContext context) {
    ref.listen<ScoutingSession>(
      scoutingSessionProvider,
      (previous, next) {
        final prevEvent = previous?.event?.key;
        final nextEvent = next.event?.key;
        final prevPos = previous?.position?.name;
        final nextPos = next.position?.name;
        if (prevEvent != nextEvent ||
            prevPos != nextPos ||
            previous?.matchNumber != next.matchNumber) {
          if (!mounted) return;
          ref.read(matchPagesProvider.notifier).loadUI(context);
        }
      },
    );
    final pagesAsync = ref.watch(matchPagesProvider);

    return pagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text(err.toString())),
      data: (pages) => Stack(children: pages[widget.index]),
    );
  }
}

// Box dataBox = Hive.box(boxKey);
// MatchIdentity currentMatchIdentity = (eventKey: "eventKey", matchNumber: 0, isRedAlliance: false, position: 0, robotNum: 0);
