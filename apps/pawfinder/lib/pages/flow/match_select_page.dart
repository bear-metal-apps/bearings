import 'package:beariscope_scouter/providers/scouting_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MatchSelectPage extends ConsumerStatefulWidget {
  const MatchSelectPage({super.key});

  @override
  ConsumerState<MatchSelectPage> createState() => _MatchSelectPageState();
}

class _MatchSelectPageState extends ConsumerState<MatchSelectPage> {
  final _matchNumberController = TextEditingController(text: '1');
  int? _matchNumber = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(scoutingSessionProvider);
      if (mounted && session.matchNumber != null) {
        setState(() {
          _matchNumber = session.matchNumber;
          _matchNumberController.text = session.matchNumber.toString();
        });
      }
    });
  }

  @override
  void dispose() {
    _matchNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(scoutingSessionProvider);

    if (session.event == null ||
        session.position == null ||
        session.scout == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/config');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final position = session.position!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/scout'),
        ),
        title: const Text('Select Match'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  session.event?.name ?? '',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Position: ${position.displayName}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Scout: ${session.scout?.name ?? "—"}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 48),

                Text(
                  'Match Number',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: TextField(
                    controller: _matchNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Match number',
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          final current =
                              int.tryParse(_matchNumberController.text) ?? 1;
                          if (current > 1) {
                            _matchNumberController.text = (current - 1)
                                .toString();
                            setState(() => _matchNumber = current - 1);
                            ref
                                .read(scoutingSessionProvider.notifier)
                                .setMatchNumber(current - 1);
                          }
                        },
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          final current =
                              int.tryParse(_matchNumberController.text) ?? 1;
                          _matchNumberController.text = (current + 1)
                              .toString();
                          setState(() => _matchNumber = current + 1);
                          ref
                              .read(scoutingSessionProvider.notifier)
                              .setMatchNumber(current + 1);
                        },
                      ),
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      setState(() {
                        _matchNumber = parsed;
                      });
                      if (parsed != null && parsed > 0) {
                        ref
                            .read(scoutingSessionProvider.notifier)
                            .setMatchNumber(parsed);
                      }
                    },
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _matchNumber != null && _matchNumber! > 0
                        ? () {
                            ref
                                .read(scoutingSessionProvider.notifier)
                                .setMatchNumber(_matchNumber!);

                            if (position.isStrategy) {
                              context.go('/strat');
                            } else {
                              context.go('/match/auto');
                            }
                          }
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Go'),
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
