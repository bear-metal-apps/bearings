import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:pawfinder/custom_widgets/upload_button.dart';
import 'package:pawfinder/data/local_data.dart';
import 'package:pawfinder/data/match_json_gen.dart';
import 'package:pawfinder/providers/scouting_providers.dart';

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
    final teamAsync = ref.watch(teamNumberForSessionProvider);
    final scheduleLastUpdated = ref.watch(scheduleLastUpdatedProvider);

    // warm up the schedule cache in advance so it's ready for scouting
    final eventKey = session.event?.key;
    if (eventKey != null) ref.watch(matchesProvider(eventKey));

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
        actionsPadding: EdgeInsets.only(right: 16),
        actions: [
          UploadButton(),
        ],
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
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Position: ${position.displayName}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'Scout: ${session.scout?.name ?? "—"}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 16),
                teamAsync.when(
                  data: (team) => Text(
                    team != null ? 'Team: $team' : 'Team: —',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: team != null
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  loading: () => const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, _) => Text(
                    'Team: —',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),

                const SizedBox(height: 16),

                _ScheduleDownloadTile(
                  eventKey: session.event!.key,
                  lastUpdated: scheduleLastUpdated,
                ),

                const SizedBox(height: 32),

                Text(
                  'Match Number',
                  style: Theme.of(context).textTheme.titleLarge,
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

                            final identity = ref
                                .read(scoutingSessionProvider.notifier)
                                .createMatchIdentity();
                            if (identity != null) {
                              final team = teamAsync.when(
                                data: (t) => t,
                                loading: () => null,
                                error: (_, _) => null,
                              );
                              if (team != null) {
                                Hive.box(
                                  boxKey,
                                ).put(matchTeamKey(identity), team);
                              }
                            }

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

class _ScheduleDownloadTile extends ConsumerStatefulWidget {
  final String eventKey;
  final DateTime? lastUpdated;

  const _ScheduleDownloadTile({
    required this.eventKey,
    required this.lastUpdated,
  });

  @override
  ConsumerState<_ScheduleDownloadTile> createState() =>
      _ScheduleDownloadTileState();
}

class _ScheduleDownloadTileState extends ConsumerState<_ScheduleDownloadTile> {
  bool _downloading = false;

  Future<void> _download() async {
    setState(() => _downloading = true);
    try {
      // invalidate to force a fetch
      ref.invalidate(eventScheduleProvider(widget.eventKey));
      await ref.read(eventScheduleProvider(widget.eventKey).future);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule downloaded'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastUpdated = widget.lastUpdated;
    final String statusText = lastUpdated != null
        ? () {
            final local = lastUpdated.toLocal();
            final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
            final m = local.minute.toString().padLeft(2, '0');
            final ampm = local.hour < 12 ? 'AM' : 'PM';
            return 'Schedule saved $h:$m $ampm';
          }()
        : 'No schedule cached';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          lastUpdated != null
              ? Icons.cloud_done_outlined
              : Icons.cloud_off_outlined,
          size: 18,
          color: lastUpdated != null
              ? theme.colorScheme.primary
              : theme.colorScheme.error,
        ),
        const SizedBox(width: 8),
        Text(statusText, style: theme.textTheme.bodySmall),
        const SizedBox(width: 12),
        _downloading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : OutlinedButton.icon(
                onPressed: _download,
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                ),
              ),
      ],
    );
  }
}
