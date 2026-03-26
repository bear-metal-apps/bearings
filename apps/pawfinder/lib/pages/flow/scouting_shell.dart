import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:pawfinder/custom_widgets/upload_status_indicator.dart';
import 'package:pawfinder/data/local_data.dart';
import 'package:pawfinder/data/match_json_gen.dart';
import 'package:pawfinder/providers/app_provider.dart';
import 'package:pawfinder/providers/scouting_flow_provider.dart';
import 'package:pawfinder/providers/scouting_providers.dart';

class ScoutingShell extends ConsumerStatefulWidget {
  final Widget child;

  const ScoutingShell({super.key, required this.child});

  @override
  ConsumerState<ScoutingShell> createState() => _ScoutingShellState();
}

class _ScoutingShellState extends ConsumerState<ScoutingShell>
    with TickerProviderStateMixin {
  late AnimationController _matchNumberController;
  late Animation<double> _matchNumberOpacity;

  @override
  void initState() {
    super.initState();
    _matchNumberController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _matchNumberOpacity = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _matchNumberController, curve: Curves.easeInOut),
    );
    
  }

  @override
  void dispose() {
    _matchNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(scoutingSessionProvider);
    final notifier = ref.read(scoutingSessionProvider.notifier);
    final matchNumber = session.matchNumber ?? 0;
    final position = session.position;

    // always contains the correct team even when navigating via prev/next.
    ref.listen<AsyncValue<int?>>(teamNumberForSessionProvider, (_, next) {
      final team = next.when(
        data: (t) => t,
        loading: () => null,
        error: (_, _) => null,
      );
      if (team == null) return;
      final identity = notifier.createMatchIdentity();
      if (identity == null) return;
      Hive.box(boxKey).put(matchTeamKey(identity), team);
    });

    final teamAsync = ref.watch(teamNumberForSessionProvider);
    final teamLabel = teamAsync.maybeWhen(
      data: (t) => t != null ? ' · $t' : 'null',
      orElse: () => '',
    );

    // Animate match number change
    ref.listen<int?>(scoutingSessionProvider.select((s) => s.matchNumber), (_, __) {
      _matchNumberController.forward(from: 0.0);
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Exit to Scout Selection',
          onPressed: () async {
            final shouldExit = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit Scouting'),
                content: const Text(
                  'Are you sure you want to exit this match?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Exit'),
                  ),
                ],
              ),
            );
            if (shouldExit ?? false) {
              notifier.exitToScoutSelect();
              if (context.mounted) {
                context.go('/scout');
              }
            }
          },
        ),

        title: Row(
          children: [
            FadeTransition(
              opacity: _matchNumberOpacity,
              child: Text('Match $matchNumber'),
            ),
            const VerticalDivider(),
            Text(position?.displayName ?? ''),
            if (teamLabel.isNotEmpty) Text(teamLabel),
          ],
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: UploadStatusIndicator(),
          ),
          LightSwitch(value: false),
          _AnimatedIconButton(
            icon: const Icon(Icons.skip_previous),
            tooltip: 'Previous Match',
            onPressed: matchNumber > 1
                ? () {
                    _matchNumberController.forward(from: 0.0);
                    ref.read(scoutingFlowControllerProvider).previousMatch();
                    context.go('/match/auto');
                  }
                : null,
          ),
          _AnimatedIconButton(
            icon: const Icon(Icons.skip_next),
            tooltip: 'Next Match',
            onPressed: () {
              _matchNumberController.forward(from: 0.0);
              ref.read(scoutingFlowControllerProvider).nextMatch();
              context.go('/match/auto');
            },
          ),
        ],
      ),
      body: ClipRect(child: widget.child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex(context),
        indicatorColor: Theme.of(context).colorScheme.primary,

        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/match/auto');
              break;
            case 1:
              context.go('/match/tele');
              break;
            case 2:
              context.go('/match/end');
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.bolt), label: 'Auto'),
          NavigationDestination(
            icon: Icon(Icons.stacked_bar_chart_sharp),
            label: 'Tele',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_array),
            label: 'Post-Match',
          ),
        ],
      ),
    );
  }

  int _currentTabIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.contains('/tele')) return 1;
    if (location.contains('/end')) return 2;
    return 0;
  }
}

/// Animated icon button with scale and rotation effects on press
class _AnimatedIconButton extends StatefulWidget {
  final Icon icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _AnimatedIconButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    if (widget.onPressed != null) {
      _controller.forward(from: 0.0);
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.8).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: IconButton(
        icon: widget.icon,
        tooltip: widget.tooltip,
        onPressed: widget.onPressed != null ? _handlePress : null,
      ),
    );
  }
}

class LightSwitch extends ConsumerStatefulWidget {
  final bool value;

  const LightSwitch({super.key, required this.value});

  @override
  ConsumerState<LightSwitch> createState() {
    return _LightSwitchState();
  }
}

class _LightSwitchState extends ConsumerState<LightSwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _value,
      onChanged: (bool value) {
        setState(() {
          _value = value;
          ref.read(brightnessNotifierProvider.notifier).changeBrightness(value);
        });
      },
    );
  }
}
