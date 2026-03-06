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
import 'package:beariscope_scouter/data/match_json_gen.dart';
import 'package:beariscope_scouter/data/upload_queue.dart';
import 'package:beariscope_scouter/models/scouting_session.dart';
import 'package:beariscope_scouter/pages/flow/scouting_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:pawfinder/custom_widgets/match_widgets/2026_specifc/big_number.dart';
import 'package:pawfinder/custom_widgets/match_widgets/bool_button.dart';
import 'package:pawfinder/custom_widgets/match_widgets/dropdown.dart';
import 'package:pawfinder/custom_widgets/match_widgets/int_button.dart';
import 'package:pawfinder/custom_widgets/match_widgets/int_textbox.dart';
import 'package:pawfinder/custom_widgets/match_widgets/segmented_button.dart';
import 'package:pawfinder/custom_widgets/match_widgets/slider.dart';
import 'package:pawfinder/custom_widgets/match_widgets/text_box.dart';
import 'package:pawfinder/custom_widgets/match_widgets/tristate.dart';
import 'package:pawfinder/data/local_data.dart';
import 'package:pawfinder/data/match_json_gen.dart';
import 'package:pawfinder/data/upload_queue.dart';
import 'package:pawfinder/pages/flow/scouting_shell.dart';
import 'package:pawfinder/providers/match_config_provider.dart';
import 'package:pawfinder/providers/scouting_flow_provider.dart';

import '../data/ui_json_serialization.dart';
import '../providers/scouting_providers.dart';

class MatchPage extends ConsumerWidget {
  final int index;

  const MatchPage({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch session so we rebuild when match/position changes
    ref.watch(scoutingSessionProvider);
    final configAsync = ref.watch(matchConfigProvider);
    final identity = ref
        .read(scoutingSessionProvider.notifier)
        .createMatchIdentity();

    return configAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (config) {
        if (identity == null || index >= config.pages.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildPage(context, ref, config, identity);
      },
    );
  }

  Widget _buildPage(
    BuildContext context,
    WidgetRef ref,
    MatchConfig config,
    MatchIdentity identity,
  ) {
    final size = MediaQuery.sizeOf(context);
    final page = config.pages[index];
    final hStep = size.width / page.width;
    final vStep = (size.height - 130) / page.height;
    final box = Hive.box(boxKey);

    final positioned = <Widget>[];

    // this is the only place we should queue match uploads now: actual edits
    void markDirty() {
      ref.read(uploadQueueProvider.notifier).addIfNotPresent(identity);
    }

    for (final data in page.components) {
      final dataBoxKey = matchDataKey(identity, page.sectionId, data.fieldId);
      final storedValue = box.get(dataBoxKey);
      final w = data.layout.w * hStep;
      final h = data.layout.h * vStep;

          Widget widget;
          switch (data.type) {
            case 'volumetric_button':
              widget = BigNumberWidget(
                key: ValueKey(dataBoxKey),
                buttons: [1, 5, -1, -5],
                width: data.layout.w * horizontalStep,
                height: data.layout.h * verticalStep,
                dataName: data.alias,
                initialValue: storedValue is int ? storedValue : null,
                onChanged: (value){
                  dataBox.put(dataBoxKey, value);
                  // if(page.sectionId == 'auto'){
                  //   startFlash();
                  // }
                },
              );
              break;
            case "int_button":
              widget = NumberButton(
                key: ValueKey(dataBoxKey),
                backgroundColor: Colors.white,
                dataName: data.alias,
                width: data.layout.w * horizontalStep,
                height: data.layout.h * verticalStep,
                initialValue: storedValue is int ? storedValue : null,
                onChanged: (value) {
                  dataBox.put(dataBoxKey, value);
                  // if(page.sectionId == 'auto'){
                  //   startFlash();
                  // }
                },
              );
              break;
            case "int_text_box":
              widget = IntTextbox(
                key: ValueKey(dataBoxKey),
                onChanged: (value) {
                  dataBox.put(dataBoxKey, value);
                  // if(page.sectionId == 'auto'){
                  //   startFlash();
                  // }
                },
                dataName: data.alias,
                width: data.layout.w * horizontalStep,
                height: data.layout.h * verticalStep,
                initialValue: storedValue is int ? storedValue : null,
              );
              break;
            case "toggle_switch":
              widget = BoolButton(
                key: ValueKey(dataBoxKey),
                dataName: data.alias,
                width: data.layout.w * horizontalStep,
                height: data.layout.h * verticalStep,
                initialValue: storedValue is bool ? storedValue : null,
                onChanged: (value) {
                  dataBox.put(dataBoxKey, value);
                  // if(page.sectionId == 'auto'){
                  //   startFlash();
                  // }
                },
                visualFeedback: true,
              );
              break;

            case "text_box":
              widget = StringTextbox(
                key: ValueKey(dataBoxKey),
                dataName: data.alias,
                width: data.layout.w * horizontalStep,
                height: data.layout.h * verticalStep,
                initialString: storedValue is String ? storedValue : null,
                onChanged: (value) {
                  dataBox.put(dataBoxKey, value);
                  // if(page.sectionId == 'auto'){
                  //   startFlash();
                  // }
                },
              );
              break;

            case "dropdown":
              List<dynamic> items = data.parameters["options"];
              int initialIndex = items.indexOf(storedValue);

              widget = Dropdown(
                key: ValueKey(dataBoxKey),
                title: data.alias,
                backgroundColor: Colors.blueAccent,
                items: items
                    .map((x) => x.toString())
                    .toList(), // darts type system is really weird
                onChanged: (value) {
                  dataBox.put(dataBoxKey, value);
                  // if(page.sectionId == 'auto'){
                  //   startFlash();
                  // }
                },
                initialIndex: initialIndex == -1 ? null : initialIndex,
                width: data.layout.w * horizontalStep,
                height: data.layout.h * verticalStep,
              );
              break;
            case "tristate":
              widget = TristateButton(
                key: ValueKey(dataBoxKey),
                dataName: data.alias,
                width: data.layout.w * horizontalStep,
                height: data.layout.h * verticalStep,
                initialValue: storedValue is int ? storedValue : null,
                onChanged: (value) {
                  dataBox.put(dataBoxKey, value);
                  // if(page.sectionId == 'auto'){
                  //   startFlash();
                  // }
                },
              );
              break;
            case "checkbox":
              widget = BoolButton(
                key: ValueKey(dataBoxKey),
                dataName: data.alias,
                width: data.layout.w * horizontalStep,
                height: data.layout.h * verticalStep,
                visualFeedback: true,
                initialValue: storedValue is bool ? storedValue : null,
                onChanged: (value) {
                  return dataBox.put(dataBoxKey, value);
                  // if(page.sectionId == 'auto'){
                  //   startFlash();
                  // }
                },
              );
              break;
            case "slider":
              final double? sliderValue = storedValue is num
                  ? storedValue.toDouble()
                  : null;
              widget = CustomSlider(
                key: ValueKey(dataBoxKey),
                onChanged: (value) {
                  dataBox.put(dataBoxKey, value);
                  // if(page.sectionId == 'auto'){
                  //   startFlash();
                  // }
                },
                title: data.alias,
                width: data.layout.w * horizontalStep,
                height: data.layout.h * verticalStep,
                minValue: 0,
                maxValue: 100,
                initialValue: sliderValue,
              );
              break;
            case "segmented_button":
              List<dynamic> items = data.parameters["options"];
              bool multiSelect = data.parameters["multi_select"] == true;
              widget = CustomSegmentedButton(
                key: ValueKey(dataBoxKey),
                segments: items.map((x) => x.toString()).toList(),
                onChanged: (value) {
                  dataBox.put(dataBoxKey, value);
                  // if(page.sectionId == 'auto'){
                  //   startFlash();
                  // }
                },
                initialValue: storedValue,
                multiSelect: multiSelect,
                width: data.layout.w * horizontalStep,
                height: data.layout.h * verticalStep,
              );
              break;
            case "Nxt":
              widget = SizedBox(
                height: data.layout.h * verticalStep,
                width: data.layout.w * horizontalStep,
                child: ElevatedButton(
                  onPressed: () {
                    final matchIdentity = ref
                        .read(scoutingSessionProvider.notifier)
                        .createMatchIdentity();
                    if (matchIdentity != null) {
                      ref
                          .read(uploadQueueProvider.notifier)
                          .addIfNotPresent(matchIdentity);
                    }
                    ref.read(scoutingSessionProvider.notifier).nextMatch();
                    context.go('/match/auto');
                  },
                  child: Text("Next Match"),
                ),
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
      Widget? widget;

      switch (data.type) {
        case 'volumetric_button':
          widget = BigNumberWidget(
            key: ValueKey(dataBoxKey),
            buttons: [1, 5, -1, -5],
            width: w,
            height: h,
            dataName: data.alias,
            initialValue: storedValue is int ? storedValue : null,
            onChanged: (value) {
              box.put(dataBoxKey, value);
              markDirty();
              if (page.sectionId == 'auto') startFlash();
            },
          );
        case 'int_button':
          widget = NumberButton(
            key: ValueKey(dataBoxKey),
            backgroundColor: Colors.white,
            dataName: data.alias,
            width: w,
            height: h,
            initialValue: storedValue is int ? storedValue : null,
            onChanged: (value) {
              box.put(dataBoxKey, value);
              markDirty();
              if (page.sectionId == 'auto') startFlash();
            },
          );
        case 'int_text_box':
          widget = IntTextbox(
            key: ValueKey(dataBoxKey),
            onChanged: (value) {
              box.put(dataBoxKey, value);
              markDirty();
              if (page.sectionId == 'auto') startFlash();
            },
            dataName: data.alias,
            width: w,
            height: h,
            initialValue: storedValue is int ? storedValue : null,
          );
        case 'toggle_switch':
          widget = BoolButton(
            key: ValueKey(dataBoxKey),
            dataName: data.alias,
            width: w,
            height: h,
            initialValue: storedValue is bool ? storedValue : null,
            onChanged: (value) {
              box.put(dataBoxKey, value);
              markDirty();
              if (page.sectionId == 'auto') startFlash();
            },
            visualFeedback: true,
          );
        case 'text_box':
          widget = StringTextbox(
            key: ValueKey(dataBoxKey),
            dataName: data.alias,
            width: w,
            height: h,
            initialString: storedValue is String ? storedValue : null,
            onChanged: (value) {
              box.put(dataBoxKey, value);
              markDirty();
              if (page.sectionId == 'auto') startFlash();
            },
          );
        case 'dropdown':
          final items = (data.parameters['options'] as List)
              .map((x) => x.toString())
              .toList();
          final initialIndex = items.indexOf(storedValue);
          widget = Dropdown(
            key: ValueKey(dataBoxKey),
            title: data.alias,
            backgroundColor: Colors.blueAccent,
            items: items,
            onChanged: (value) {
              box.put(dataBoxKey, value);
              markDirty();
              if (page.sectionId == 'auto') startFlash();
            },
            initialIndex: initialIndex == -1 ? null : initialIndex,
            width: w,
            height: h,
          );
        case 'tristate':
          widget = TristateButton(
            key: ValueKey(dataBoxKey),
            dataName: data.alias,
            width: w,
            height: h,
            initialValue: storedValue is int ? storedValue : null,
            onChanged: (value) {
              box.put(dataBoxKey, value);
              markDirty();
              if (page.sectionId == 'auto') startFlash();
            },
          );
        case 'checkbox':
          widget = BoolButton(
            key: ValueKey(dataBoxKey),
            dataName: data.alias,
            width: w,
            height: h,
            visualFeedback: true,
            initialValue: storedValue is bool ? storedValue : null,
            onChanged: (value) {
              box.put(dataBoxKey, value);
              markDirty();
            },
          );
        case 'slider':
          widget = CustomSlider(
            key: ValueKey(dataBoxKey),
            onChanged: (value) {
              box.put(dataBoxKey, value);
              markDirty();
              if (page.sectionId == 'auto') startFlash();
            },
            title: data.alias,
            width: w,
            height: h,
            minValue: 0,
            maxValue: 100,
            initialValue: storedValue is num ? storedValue.toDouble() : null,
          );
        case 'segmented_button':
          final items = data.parameters['options'] as List;
          int? initialIndex;
          if (storedValue is int) {
            initialIndex = (storedValue >= 0 && storedValue < items.length)
                ? storedValue
                : null;
          } else if (storedValue is String) {
            final idx = items.indexOf(storedValue);
            initialIndex = idx >= 0 ? idx : null;
          }
          widget = CustomSegmentedButton(
            key: ValueKey(dataBoxKey),
            segments: items.map((x) => x.toString()).toList(),
            onChanged: (value) {
              box.put(dataBoxKey, value);
              markDirty();
              if (page.sectionId == 'auto') startFlash();
            },
            initialIndex: initialIndex,
            width: w,
            height: h,
          );
        case 'Nxt':
          widget = SizedBox(
            width: w,
            height: h,
            child: ElevatedButton(
              onPressed: () {
                ref.read(scoutingFlowControllerProvider).nextMatch();
                context.go('/match/auto');
              },
              child: const Text('Next Match'),
            ),
          );
        default:
          continue;
      }

      positioned.add(
        Positioned(
          top: data.layout.y * vStep,
          left: data.layout.x * hStep,
          child: widget,
        ),
      );
    }

    return Stack(children: positioned);
  }
}
