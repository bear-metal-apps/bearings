import 'package:flutter/material.dart';
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
import 'package:pawfinder/data/ui_json_serialization.dart';
import 'package:pawfinder/data/upload_queue.dart';
import 'package:pawfinder/providers/match_config_provider.dart';
import 'package:pawfinder/providers/scouting_flow_provider.dart';
import 'package:pawfinder/providers/scouting_providers.dart';

class MatchPage extends ConsumerWidget {
  final int index;

  const MatchPage({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(scoutingSessionProvider);
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
        // passes resetVersion to the builder
        return _buildPage(
          context,
          ref,
          config,
          identity,
          session.resetVersion ?? 0,
        );
      },
    );
  }

  Widget _buildPage(
    BuildContext context,
    WidgetRef ref,
    MatchConfig config,
    MatchIdentity identity,
    int version,
  ) {
    final page = config.pages[index];
    final box = Hive.box(boxKey);

    return LayoutBuilder(
      builder: (context, constraints) {
        final hStep = constraints.maxWidth / page.width;
        final vStep = constraints.maxHeight / page.height;
        final positioned = <Widget>[];

        void markDirty() {
          box.put(matchScoutedByKey(identity), identity.scout.name);
          ref.read(uploadQueueProvider.notifier).addIfNotPresent(identity);
        }

        for (final data in page.components) {
          final dataBoxKey = matchDataKey(
            identity,
            page.sectionId,
            data.fieldId,
          );
          final storedValue = box.get(dataBoxKey);
          final w = data.layout.w * hStep;
          final h = data.layout.h * vStep;

          // include version to force hard reset
          final widgetKey = ValueKey('${dataBoxKey}_v$version');

          Widget? widget;
          switch (data.type) {
            case 'volumetric_button':
              widget = BigNumberWidget(
                key: widgetKey,
                buttons: const [1, 5, -1, -5],
                width: w,
                height: h,
                dataName: data.alias,
                initialValue: storedValue is int ? storedValue : null,
                onChanged: (v) {
                  box.put(dataBoxKey, v);
                  markDirty();
                },
              );
              break;
            case 'int_button':
              widget = NumberButton(
                key: widgetKey,
                dataName: data.alias,
                width: w,
                height: h,
                initialValue: storedValue is int ? storedValue : null,
                onChanged: (v) {
                  box.put(dataBoxKey, v);
                  markDirty();
                },
              );
              break;
            case 'int_text_box':
              widget = IntTextbox(
                key: widgetKey,
                onChanged: (v) {
                  box.put(dataBoxKey, v);
                  markDirty();
                },
                dataName: data.alias,
                width: w,
                height: h,
                initialValue: storedValue is int ? storedValue : null,
              );
              break;
            case 'toggle_switch':
              widget = BoolButton(
                key: widgetKey,
                dataName: data.alias,
                width: w,
                height: h,
                initialValue: storedValue is bool ? storedValue : null,
                onChanged: (v) {
                  box.put(dataBoxKey, v);
                  markDirty();
                },
                visualFeedback: true,
              );
              break;
            case 'text_box':
              widget = StringTextbox(
                key: widgetKey,
                dataName: data.alias,
                width: w,
                height: h,
                initialString: storedValue is String ? storedValue : null,
                onChanged: (v) {
                  box.put(dataBoxKey, v);
                  markDirty();
                },
              );
              break;
            case 'dropdown':
              final items = (data.parameters['options'] as List)
                  .map((x) => x.toString())
                  .toList();
              widget = Dropdown(
                key: widgetKey,
                title: data.alias,
                backgroundColor: Colors.blueAccent,
                items: items,
                onChanged: (v) {
                  box.put(dataBoxKey, v);
                  markDirty();
                },
                // ignore: prefer_contains
                initialIndex: items.indexOf(storedValue) == -1
                    ? null
                    : items.indexOf(storedValue),
                width: w,
                height: h,
              );
              break;
            case 'tristate':
              widget = TristateButton(
                key: widgetKey,
                dataName: data.alias,
                width: w,
                height: h,
                initialValue: storedValue is int ? storedValue : null,
                onChanged: (v) {
                  box.put(dataBoxKey, v);
                  markDirty();
                },
              );
              break;
            case 'checkbox':
              widget = BoolButton(
                key: widgetKey,
                dataName: data.alias,
                width: w,
                height: h,
                visualFeedback: true,
                initialValue: storedValue is bool ? storedValue : null,
                onChanged: (v) {
                  box.put(dataBoxKey, v);
                  markDirty();
                },
              );
              break;
            case 'slider':
              widget = CustomSlider(
                key: widgetKey,
                onChanged: (v) {
                  box.put(dataBoxKey, v);
                  markDirty();
                },
                title: data.alias,
                width: w,
                height: h,
                minValue: 0,
                maxValue: 100,
                initialValue: storedValue is num
                    ? storedValue.toDouble()
                    : null,
              );
              break;
            case 'segmented_button':
              final items = data.parameters['options'] as List;
              final isMultiSelect = data.parameters['multi_select'] == true;
              widget = CustomSegmentedButton(
                key: widgetKey,
                segments: items.map((x) => x.toString()).toList(),
                multiSelect: isMultiSelect,
                onChanged: (v) {
                  box.put(dataBoxKey, v);
                  markDirty();
                },
                initialValue: isMultiSelect
                    ? (storedValue is List ? storedValue : null)
                    : (storedValue is int ? storedValue : null),
                width: w,
                height: h,
              );
              break;
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
              break;
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
      },
    );
  }
}
