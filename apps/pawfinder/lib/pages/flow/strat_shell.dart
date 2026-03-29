import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pawfinder/providers/scouting_flow_provider.dart';
import 'package:pawfinder/providers/scouting_providers.dart';

class StratShell extends ConsumerStatefulWidget {
  final Widget child;

  const StratShell({super.key, required this.child});

  @override
  ConsumerState<StratShell> createState() => _StratShellState();
}

class _StratShellState extends ConsumerState<StratShell>
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
    final flow = ref.read(scoutingFlowControllerProvider);
    final matchNumber = session.matchNumber ?? 0;

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
            Text(session.position?.displayName ?? 'Strategy'),
          ],
        ),
        actions: [
          Row(
            children: [
              _AnimatedIconButton(
                icon: const Icon(Icons.skip_previous),
                tooltip: 'Previous Match',
                onPressed: matchNumber > 1
                    ? () {
                        _matchNumberController.forward(from: 0.0);
                        flow.previousMatch();
                      }
                    : null,
              ),
              _AnimatedIconButton(
                icon: const Icon(Icons.skip_next),
                tooltip: 'Next Match',
                onPressed: () {
                  _matchNumberController.forward(from: 0.0);
                  flow.nextMatch();
                },
              ),
            ],
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0.06, 0),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(matchNumber),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Animated icon button with scale effect on press
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
