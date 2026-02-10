import 'dart:convert';

import 'package:beariscope_scouter/custom_widgets/big_number.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/bool_button.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/dropdown.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/int_button.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/slider.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/text_box.dart';
import 'package:beariscope_scouter/custom_widgets/match_widgets/tristate.dart';
import 'package:beariscope_scouter/data/local_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import '../data/ui_json_serialization.dart';

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
          final dataBoxKey = "MATCH_eventkey_${data.fieldId}";

          Widget widget;
          switch (data.type) {
            case 'volumetric_button':
              widget = BigNumberWidget(
                buttons: [1, 5, 10, -1, -5, -10],
                xLength: data.layout.w * horizontalStep,
                yLength: data.layout.h * verticalStep,
                text: data.alias,
                onChanged: (value) => dataBox.put(dataBoxKey, value),
              );
              break;
            case "int_button":
              widget = NumberButton(
                backgroundColor: Colors.white,
                dataName: data.alias,
                xLength: data.layout.w * horizontalStep,
                yLength: data.layout.h * verticalStep,
                onChanged: (value) => dataBox.put(dataBoxKey, value),
              );
              break;

            case "toggle_switch":
              widget = BoolButton(
                dataName: data.alias,
                xLength: data.layout.w * horizontalStep,
                yLength: data.layout.h * verticalStep,
                initialValue: dataBox.get(dataBoxKey),
                onChanged: (value) => dataBox.put(dataBoxKey, value),
                visualFeedback: true,
              );
              break;

            case "text_box":
              widget = StringTextbox(
                dataName: data.alias,
                xLength: data.layout.w * horizontalStep,
                yLength: data.layout.h * verticalStep,
                onChanged: (value) => dataBox.put(dataBoxKey, value),
              );
              break;

            case "dropdown":
              widget = Dropdown(
                title: '',
                backgroundColor: Colors.blueAccent,
                items: ["please", "work"],
                onChanged: (value) => dataBox.put(dataBoxKey, value),
                xValue: data.layout.w * horizontalStep,
                yValue: data.layout.h * verticalStep,
              );
              break;
            case "tristate":
              widget = TristateButton(
                dataName: data.alias,
                xLength: data.layout.w * horizontalStep,
                yLength: data.layout.h * verticalStep,
                initialState: dataBox.get(dataBoxKey),
                onChanged: (value) => dataBox.put(dataBoxKey, value),
              );
              break;
            case "checkbox":
              widget = BoolButton(
                dataName: data.alias,
                xLength: data.layout.w * horizontalStep,
                yLength: data.layout.h * verticalStep,
                visualFeedback: true,
                onChanged: (value) => dataBox.put(dataBoxKey, value),
              );
              break;
            case "slider":
              widget = CustomSlider(
                onChanged: (value) => dataBox.put(dataBoxKey, value),
                title: data.alias,
                xValue: data.layout.w * horizontalStep,
                yValue: data.layout.h * verticalStep,
                minValue: 0,
                maxValue: 10,
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
