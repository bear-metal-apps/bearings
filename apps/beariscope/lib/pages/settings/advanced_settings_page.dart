import 'dart:async';

import 'package:beariscope/components/settings_group.dart';
import 'package:beariscope/providers/tba_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:services/providers/connectivity_provider.dart';

class AdvancedSettingsPage extends ConsumerStatefulWidget {
  const AdvancedSettingsPage({super.key});

  @override
  ConsumerState<AdvancedSettingsPage> createState() =>
      _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends ConsumerState<AdvancedSettingsPage> {
  final TextEditingController _customHoneycombUrlController =
  TextEditingController();

  @override
  void dispose() {
    _customHoneycombUrlController.dispose();
    super.dispose();
  }

  String? _customUrlError(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Enter a custom endpoint URL.';
    }

    final parsed = Uri.tryParse(trimmed);
    if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) {
      return 'Enter a valid absolute URL, like https://example.com.';
    }

    return null;
  }

  void _syncCustomUrlController(HoneycombEndpointSelection selection) {
    final desiredText = selection.customUrl ?? '';
    if (_customHoneycombUrlController.text == desiredText) return;

    _customHoneycombUrlController.value = TextEditingValue(
      text: desiredText,
      selection: TextSelection.collapsed(offset: desiredText.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final useBetaTbaWebsite = ref.watch(useBetaTbaWebsiteProvider);
    final endpointSelection = ref.watch(honeycombEndpointPreferenceProvider);
    _syncCustomUrlController(endpointSelection);

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
          const SizedBox(height: 16),
          SettingsGroup(
            title: 'Server Connection',
            children: [
              RadioListTile<HoneycombEndpointMode>(
                value: HoneycombEndpointMode.azure,
                groupValue: endpointSelection.mode,
                title: const Text('Azure'),
                subtitle: const Text('Use the main Azure server'),
                onChanged: (_) =>
                    unawaited(
                      ref
                          .read(honeycombEndpointPreferenceProvider.notifier)
                          .setAzure(),
                    ),
              ),
              RadioListTile<HoneycombEndpointMode>(
                value: HoneycombEndpointMode.cloudflare,
                groupValue: endpointSelection.mode,
                title: const Text('Proxy'),
                subtitle: const Text(
                    'Proxy the server through Cloudflare, useful if Azure is blocked'),
                onChanged: (_) =>
                    unawaited(
                      ref
                          .read(honeycombEndpointPreferenceProvider.notifier)
                          .setCloudflare(),
                    ),
              ),
              RadioListTile<HoneycombEndpointMode>(
                value: HoneycombEndpointMode.custom,
                groupValue: endpointSelection.mode,
                title: const Text('Custom URL'),
                subtitle: const Text('Use a custom server'),
                onChanged: (_) =>
                    unawaited(
                      ref
                          .read(honeycombEndpointPreferenceProvider.notifier)
                          .setCustomUrl(
                        _customHoneycombUrlController.text,
                      ),
                    ),
              ),
              if (endpointSelection.mode == HoneycombEndpointMode.custom)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: TextField(
                    controller: _customHoneycombUrlController,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Custom URL',
                      helperText: 'Enter the endpoint origin, such as https://example.com',
                      errorText: _customUrlError(
                          _customHoneycombUrlController.text),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (endpointSelection.mode !=
                          HoneycombEndpointMode.custom) {
                        return;
                      }
                      unawaited(
                        ref
                            .read(honeycombEndpointPreferenceProvider.notifier)
                            .setCustomUrl(value),
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
