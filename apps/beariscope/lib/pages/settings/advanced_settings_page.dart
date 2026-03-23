import 'package:beariscope/components/settings_group.dart';
import 'package:beariscope/providers/tba_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class AdvancedSettingsPage extends ConsumerWidget {
  const AdvancedSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useBetaTbaWebsite = ref.watch(useBetaTbaWebsiteProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Advanced')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          SettingsGroup(
            title: 'Data Sources',
            children: [
              SwitchListTile(
                secondary: const Icon(Symbols.experiment_rounded),
                title: const Text('Use beta TBA website'),
                subtitle: const Text(
                  'Use The Blue Alliance\'s beta redesign for in-app links',
                ),
                value: useBetaTbaWebsite,
                onChanged: (value) => ref
                    .read(useBetaTbaWebsiteProvider.notifier)
                    .setUseBetaTbaWebsite(value),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
