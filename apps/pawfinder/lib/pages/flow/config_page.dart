import 'package:beariscope_scouter/models/scouting_session.dart';
import 'package:beariscope_scouter/providers/scouting_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ConfigPage extends ConsumerStatefulWidget {
  const ConfigPage({super.key});

  @override
  ConsumerState<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends ConsumerState<ConfigPage> {
  ScoutingEvent? _selectedEvent;
  ScoutPosition? _selectedPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(scoutingSessionProvider);
      if (mounted) {
        setState(() {
          _selectedEvent = session.event;
          _selectedPosition = session.position;
        });
      }
    });
  }

  Future<void> _showPasswordDialog(BuildContext context) async {
    final TextEditingController passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Password'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Password',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(passwordController.text),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (password == '2026scout' && context.mounted) {
      context.push('/config/settings');
    } else if (password != null && password.isNotEmpty && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Comp and Position'),
        actionsPadding: EdgeInsets.only(right: 8),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => _showPasswordDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Position',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _PositionSelector(
                  selected: _selectedPosition,
                  onChanged: (pos) {
                    setState(() => _selectedPosition = pos);
                    ref.read(scoutingSessionProvider.notifier).setPosition(pos);
                  },
                ),

                const SizedBox(height: 32),

                Text(
                  'Competition',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                eventsAsync.when(
                  data: (events) => DropdownButtonFormField<ScoutingEvent>(
                    initialValue: _selectedEvent,
                    padding: EdgeInsets.all(4),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      hintText: 'Select a competition',
                    ),
                    items: events
                        .map(
                          (e) =>
                              DropdownMenuItem(value: e, child: Text(e.name)),
                        )
                        .toList(),
                    onChanged: (event) {
                      setState(() => _selectedEvent = event);
                      if (event != null) {
                        ref
                            .read(scoutingSessionProvider.notifier)
                            .setEvent(event);
                      }
                    },
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => _ErrorRetry(
                    message: 'Failed to load competitions',
                    onRetry: () => ref.invalidate(eventsProvider),
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed:
                        _selectedEvent != null && _selectedPosition != null
                        ? () {
                            final notifier = ref.read(
                              scoutingSessionProvider.notifier,
                            );
                            notifier.setEvent(_selectedEvent!);
                            notifier.setPosition(_selectedPosition!);
                            context.go('/scout');
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PositionSelector extends StatelessWidget {
  final ScoutPosition? selected;
  final ValueChanged<ScoutPosition> onChanged;

  const _PositionSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _allianceRow(
          context,
          label: 'Red Alliance',
          color: Colors.red,
          positions: [
            ScoutPosition.red1,
            ScoutPosition.red2,
            ScoutPosition.red3,
            ScoutPosition.redStrat,
          ],
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 8),
        _allianceRow(
          context,
          label: 'Blue Alliance',
          color: Colors.blue,
          positions: [
            ScoutPosition.blue1,
            ScoutPosition.blue2,
            ScoutPosition.blue3,
            ScoutPosition.blueStrat,
          ],
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _allianceRow(
    BuildContext context, {
    required String label,
    required Color color,
    required List<ScoutPosition> positions,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<ScoutPosition>(
            segments: positions.map((pos) {
              return ButtonSegment<ScoutPosition>(
                value: pos,
                label: Text(pos.displayName),
              );
            }).toList(),
            selected: selected != null && positions.contains(selected)
                ? {selected!}
                : {},
            emptySelectionAllowed: true,
            onSelectionChanged: (Set<ScoutPosition> selection) {
              if (selection.isNotEmpty) {
                onChanged(selection.first);
              }
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return color.withValues(alpha: 0.3);
                }
                return colorScheme.surface;
              }),
              foregroundColor: WidgetStateProperty.resolveWith<Color>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return colorScheme.onSurface;
                }
                return colorScheme.onSurface.withValues(alpha: 0.7);
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}
