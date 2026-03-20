import 'package:beariscope/components/beariscope_card.dart';
import 'package:beariscope/pages/main_view.dart';
import 'package:beariscope/pages/up_next/up_next_provider.dart';
import 'package:beariscope/pages/up_next/up_next_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:services/providers/api_provider.dart';

enum _MatchFilter { all, bearMetal }

class UpNextPage extends ConsumerStatefulWidget {
  const UpNextPage({super.key});

  static final DateFormat timeFormat = DateFormat("EEEE, MMM d 'at' h:mm a");
  static final DateFormat eventDateFormat = DateFormat('EEEE, MMM d');

  @override
  ConsumerState<UpNextPage> createState() => _UpNextPageState();
}

class _UpNextPageState extends ConsumerState<UpNextPage> {
  _MatchFilter _filter = _MatchFilter.bearMetal;

  @override
  Widget build(BuildContext context) {
    final controller = MainViewController.of(context);
    final scheduleAsync = ref.watch(upcomingScheduleProvider);

    Future<void> refreshSchedule() async {
      final client = ref.read(honeycombClientProvider);
      client.invalidateCache('/events?year=2026');
      client.invalidateCache('/matches?year=2026');
      ref.invalidate(upcomingScheduleProvider);
      try {
        await ref.read(upcomingScheduleProvider.future);
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Up Next'),
        leading: controller.isDesktop
            ? null
            : IconButton(
                icon: const Icon(Symbols.menu_rounded),
                onPressed: controller.openDrawer,
              ),
        actionsPadding: const EdgeInsets.only(right: 12.0),
        actions: [
          PopupMenuButton<_MatchFilter>(
            icon: Icon(
              _filter == _MatchFilter.bearMetal
                  ? Symbols.filter_list_rounded
                  : Symbols.filter_list_off_rounded,
              color: _filter == _MatchFilter.bearMetal
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (context) => [
              _filterMenuItem(
                value: _MatchFilter.all,
                label: 'All Matches',
                current: _filter,
              ),
              _filterMenuItem(
                value: _MatchFilter.bearMetal,
                label: 'Just 2046',
                current: _filter,
              ),
            ],
          ),
        ],
      ),
      body: scheduleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error fetching schedule: $err')),
        data: (schedule) {
          final currentEvents = <Map<String, dynamic>>[];

          for (final item in schedule) {
            if (_filter == _MatchFilter.all) {
              currentEvents.add(item);
            } else {
              final filtered = _filterForTeam(item, 'frc2046');
              if (filtered != null) currentEvents.add(filtered);
            }
          }

          return _EventList(
            items: currentEvents,
            emptyMessage: 'No matches found',
            timeFormat: UpNextPage.timeFormat,
            onRefresh: refreshSchedule,
          );
        },
      ),
    );
  }
}

PopupMenuItem<_MatchFilter> _filterMenuItem({
  required _MatchFilter value,
  required String label,
  required _MatchFilter current,
}) {
  return PopupMenuItem<_MatchFilter>(
    value: value,
    child: Row(
      children: [
        SizedBox(
          width: 32,
          child: current == value
              ? const Icon(Symbols.check_rounded, size: 20)
              : null,
        ),
        Text(label),
      ],
    ),
  );
}

Map<String, dynamic>? _filterForTeam(Map<String, dynamic> item,
    String teamKey,) {
  final matches = (item['matches'] as List?)
      ?.whereType<Map>()
      .map((m) => Map<String, dynamic>.from(m))
      .toList();

  if (matches == null || matches.isEmpty) return null;

  final teamMatches = matches.where((m) => _isTeamInMatch(m, teamKey)).toList();

  if (teamMatches.isEmpty) return null;

  return {...item, 'matches': teamMatches};
}

bool _isTeamInMatch(Map<String, dynamic> match, String teamKey) {
  final alliances = match['alliances'] as Map?;
  if (alliances == null) return false;

  for (final alliance in alliances.values) {
    if (alliance is! Map) continue;
    final keys =
        (alliance['team_keys'] ?? alliance['teamKeys'] ?? alliance['teams'])
            as List?;
    if (keys != null && keys.any((k) => k?.toString() == teamKey)) {
      return true;
    }
  }

  return false;
}

class _EventSection extends StatelessWidget {
  final Map<String, dynamic> data;
  final DateFormat timeFormat;

  const _EventSection({required this.data, required this.timeFormat});

  @override
  Widget build(BuildContext context) {
    final event = data['event'] as Map<String, dynamic>;
    final matches =
        (data['matches'] as List?)
            ?.whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .toList() ??
        const <Map<String, dynamic>>[];
    final eventName = event['name']?.toString() ?? 'Unknown Event';

    if (matches.isEmpty) {
      return UpNextEventCard(
        eventKey: event['key']?.toString() ?? '',
        name: eventName,
        dateLabel: _formatEventDate(event),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Text(eventName, style: const TextStyle(fontFamily: 'Xolonium')),
          ...matches.map((match) {
            final matchTime = _parseMatchTime(match);
            final timeLabel = matchTime == null
                ? 'Time TBD'
                : timeFormat.format(matchTime);

            String displayName;
            final compLevel = _stringValue(match, 'compLevel', 'comp_level');
            final matchNumber = _intValue(match, 'matchNumber', 'match_number');
            switch (compLevel) {
              case 'qm':
                displayName = 'Qualification Match ${matchNumber ?? ''}'.trim();
              case 'sf':
                displayName = 'Semifinal Match ${matchNumber ?? ''}'.trim();
              case 'f':
                displayName = 'Final Match ${matchNumber ?? ''}'.trim();
              default:
                displayName = _defaultMatchName(match, compLevel, matchNumber);
            }

            return UpNextMatchCard(
              matchKey: match['key']?.toString() ?? '',
              displayName: displayName,
              time: timeLabel,
            );
          }),
        ],
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String emptyMessage;
  final DateFormat timeFormat;
  final Future<void> Function() onRefresh;

  const _EventList({
    required this.items,
    required this.emptyMessage,
    required this.timeFormat,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 320, child: Center(child: Text(emptyMessage))),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: BeariscopeCardList(
        children: items.map((item) {
          return _EventSection(data: item, timeFormat: timeFormat);
        }).toList(),
      ),
    );
  }
}

String _formatEventDate(Map<String, dynamic> event) {
  final startDate = _parseDate(event['startDate'] ?? event['start_date']);
  if (startDate == null) return 'Date TBA';
  return UpNextPage.eventDateFormat.format(startDate);
}

DateTime? _parseMatchTime(Map<String, dynamic> match) {
  final value = match['predictedTime'] ?? match['predicted_time'];
  if (value is String) return DateTime.tryParse(value);
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value * 1000);
  return null;
}

DateTime? _parseDate(dynamic value) {
  if (value is String) return DateTime.tryParse(value);
  return null;
}

String _stringValue(Map<String, dynamic> map, String primary, String fallback) {
  return map[primary]?.toString() ?? map[fallback]?.toString() ?? '';
}

int? _intValue(Map<String, dynamic> map, String primary, String fallback) {
  final value = map[primary] ?? map[fallback];
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

String _defaultMatchName(Map<String, dynamic> match,
    String compLevel,
    int? matchNumber,) {
  if (compLevel.isEmpty) return match['key']?.toString() ?? '';
  if (matchNumber != null) return '$compLevel $matchNumber';
  return compLevel;
}
