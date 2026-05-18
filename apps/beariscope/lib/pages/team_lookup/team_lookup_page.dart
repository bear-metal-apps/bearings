import 'package:beariscope/models/match_field_ids.dart';
import 'package:beariscope/pages/main_view.dart';
import 'package:beariscope/pages/team_lookup/team_model.dart';
import 'package:beariscope/pages/team_lookup/team_providers.dart';
import 'package:beariscope/providers/current_event_provider.dart';
import 'package:beariscope/providers/rankings_provider.dart';
import 'package:beariscope/providers/team_scouting_provider.dart';
import 'package:beariscope/widgets/beariscope_card.dart';
import 'package:beariscope/widgets/team_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:services/providers/api_provider.dart';

final collectedTeamsProvider = StateProvider<List<String>>((ref) => []);
final isDraggingProvider = StateProvider<bool>((ref) => false);
final compareSheetVisibleProvider = StateProvider<bool>((ref) => false);

class TeamLookupPage extends ConsumerStatefulWidget {
  const TeamLookupPage({super.key});

  @override
  ConsumerState<TeamLookupPage> createState() => _TeamLookupPageState();
}

class _TeamLookupPageState extends ConsumerState<TeamLookupPage> {
  final TextEditingController _searchTermTEC = TextEditingController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  static const double _collapsedSheetHeight = 84.0;
  static const double _expandedSheetHeight = 700.0;

  @override
  void dispose() {
    _searchTermTEC.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = MainViewController.of(context);
    final selectedEvent = ref.watch(currentEventProvider);
    final teamsAsync = ref.watch(teamsProvider);
    final collectedTeams = ref.watch(collectedTeamsProvider);
    final isCompareSheetVisible = ref.watch(compareSheetVisibleProvider);
    final selectedSort = ref.watch(teamSortProvider);
    final rankingsAsync = ref.watch(eventRankingsProvider);
    final rankings = switch (rankingsAsync) {
      AsyncData(:final value) => value,
      _ => const <int, TeamRanking>{},
    };
    bool isAscending = ref.read(teamSortProvider.notifier).getIsAscending();

    Future<void> onRefresh() async {
      final client = ref.read(honeycombClientProvider);
      client.invalidateCache('/teams', queryParams: {'event': selectedEvent});
      client.invalidateCache(
        '/rankings',
        queryParams: {'event': selectedEvent},
      );
      client.invalidateCache('/event/$selectedEvent/team_media');
      ref.invalidate(teamsProvider);
      ref.invalidate(eventRankingsProvider);
      ref.invalidate(eventTeamMediaProvider);
      try {
        await Future.wait([
          ref.read(teamsProvider.future),
          ref.read(eventRankingsProvider.future),
          ref.read(eventTeamMediaProvider.future),
        ]);
      } catch (_) {
        // Keep current cached data visible if refresh fails.
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
        leading: controller.isDesktop
            ? null
            : IconButton(
                icon: const Icon(LucideIcons.menu),
                onPressed: controller.openDrawer,
              ),
        actions: [
          PopupMenuButton<TeamSortOptions>(
            icon: Icon(
              isAscending
                  ? LucideIcons.arrowUpNarrowWide
                  : LucideIcons.arrowDownWideNarrow,
            ),
            tooltip: 'Sort',
            itemBuilder: (context) => TeamSortOptions.values
                .map(
                  (sort) => CheckedPopupMenuItem<TeamSortOptions>(
                    value: sort,
                    checked: selectedSort.sort == sort,
                    child: Row(
                      children: [
                        Text(sort.label),
                        if (selectedSort.sort == sort)
                          Icon(
                            isAscending
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                          ),
                      ],
                    ),
                  ),
                )
                .toList(),
            onSelected: (TeamSortOptions newSort) {
              if (ref.read(teamSortProvider.notifier).getSort() == newSort) {
                isAscending = !isAscending;
              }

              ref.read(teamSortProvider.notifier).setSort(newSort, isAscending);
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: _sheetController,
            builder: (context, _) {
              final showCompareSheet =
                  collectedTeams.isNotEmpty || isCompareSheetVisible;
              final collapsedSheetFraction =
                  _collapsedSheetHeight / constraints.maxHeight;

              final searchBarBottom =
                  showCompareSheet &&
                      (!_sheetController.isAttached ||
                          _sheetController.size <=
                              collapsedSheetFraction + 0.01)
                  ? _collapsedSheetHeight + 8
                  : 8.0;

              return Stack(
                children: [
                  teamsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) =>
                        Center(child: Text('Error: $error')),
                    data: (teams) {
                      final teamList = teams
                          .whereType<Map<String, dynamic>>()
                          .map((json) => Team.fromJson(json))
                          .toList();

                      final searchTerm = _searchTermTEC.text
                          .trim()
                          .toLowerCase();

                      var filteredTeams = searchTerm.isEmpty
                          ? teamList
                          : teamList.where((team) {
                              final teamName = team.name.toLowerCase();
                              final teamNumber = team.number.toString();
                              final teamKey = team.key.toLowerCase();

                              return teamName.contains(searchTerm) ||
                                  teamNumber.contains(searchTerm) ||
                                  teamKey.contains(searchTerm);
                            }).toList();

                      filteredTeams = List.of(filteredTeams);
                      switch (selectedSort.sort) {
                        case TeamSortOptions.teamNumber:
                          if (isAscending) {
                            filteredTeams.sort(
                              (a, b) => a.number.compareTo(b.number),
                            );
                          } else {
                            filteredTeams.sort(
                              (a, b) => b.number.compareTo(a.number),
                            );
                          }
                        case TeamSortOptions.rank:
                          if (isAscending) {
                            filteredTeams.sort((a, b) {
                              // Teams without a rank go to the end
                              final rankA = rankings[a.number]?.rank ?? 999999;
                              final rankB = rankings[b.number]?.rank ?? 999999;
                              return rankA.compareTo(rankB);
                            });
                          } else {
                            filteredTeams.sort((a, b) {
                              final rankA = rankings[a.number]?.rank ?? 0;
                              final rankB = rankings[b.number]?.rank ?? 0;
                              return rankB.compareTo(rankA);
                            });
                          }
                        case TeamSortOptions.custom:
                          filteredTeams.sort((a, b) {
                            final rankA = ref
                                .watch(teamScoutingProvider(a.number))
                                .when(
                                  data: (bundle) =>
                                      bundle.avgMatchField(
                                        kSectionTele,
                                        kTeleFuelScored,
                                      ) +
                                      bundle.avgMatchField(
                                        kSectionAuto,
                                        kAutoFuelScored,
                                      ),
                                  error: (_, _) => 0,
                                  loading: () => 0,
                                );
                            final rankB = ref
                                .watch(teamScoutingProvider(b.number))
                                .when(
                                  data: (bundle) =>
                                      bundle.avgMatchField(
                                        kSectionTele,
                                        kTeleFuelScored,
                                      ) +
                                      bundle.avgMatchField(
                                        kSectionAuto,
                                        kAutoFuelScored,
                                      ),
                                  error: (_, _) => 0,
                                  loading: () => 0,
                                );
                            if (isAscending) {
                              return rankA.compareTo(rankB);
                            } else {
                              return rankB.compareTo(rankA);
                            }
                          });
                      }

                      if (filteredTeams.isEmpty) {
                        return const Center(child: Text('No teams found'));
                      }

                      return RefreshIndicator(
                        onRefresh: onRefresh,
                        child: BeariscopeCardList(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                          children: filteredTeams.map((team) {
                            return LongPressDraggable<String>(
                              data: team.key,
                              onDragStarted: () {
                                HapticFeedback.lightImpact();
                                ref.read(isDraggingProvider.notifier).state =
                                    true;
                                ref
                                        .read(
                                          compareSheetVisibleProvider.notifier,
                                        )
                                        .state =
                                    true;

                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (!mounted ||
                                      !_sheetController.isAttached) {
                                    return;
                                  }

                                  _sheetController.animateTo(
                                    0.25, // Peeks open just enough
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeOutBack,
                                  );
                                });
                              },
                              onDragEnd: (details) {
                                ref.read(isDraggingProvider.notifier).state =
                                    false;

                                if (ref
                                    .read(collectedTeamsProvider)
                                    .isNotEmpty) {
                                  _sheetController.animateTo(
                                    _TeamLookupPageState._collapsedSheetHeight /
                                        MediaQuery.of(context).size.height,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutBack,
                                  );
                                } else if (_sheetController.isAttached) {
                                  _sheetController.animateTo(
                                    0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutBack,
                                  );

                                  Future.delayed(
                                    const Duration(milliseconds: 300),
                                    () {
                                      if (!mounted) {
                                        return;
                                      }

                                      ref
                                              .read(
                                                compareSheetVisibleProvider
                                                    .notifier,
                                              )
                                              .state =
                                          false;
                                    },
                                  );
                                } else {
                                  ref
                                          .read(
                                            compareSheetVisibleProvider
                                                .notifier,
                                          )
                                          .state =
                                      false;
                                }
                              },

                              feedback: Material(
                                elevation: 16.0,
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width - 32,
                                  child: Transform.rotate(
                                    angle: 0.05,
                                    // Slight tilt makes it feel "picked up"
                                    child: Opacity(
                                      opacity: 0.95,
                                      child: TeamCard(teamKey: team.key),
                                    ),
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: TeamCard(teamKey: team.key),
                              ),
                              child: TeamCard(teamKey: team.key),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),

                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    left: 8,
                    right: 8,
                    bottom: searchBarBottom,
                    child: SafeArea(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onVerticalDragEnd: (details) {
                          if ((details.primaryVelocity ?? 0) > 0) {
                            FocusScope.of(context).unfocus();
                          }
                        },
                        child: SearchBar(
                          controller: _searchTermTEC,
                          onChanged: (_) => setState(() {}),
                          hintText: 'Team name or number',
                          padding: const WidgetStatePropertyAll<EdgeInsets>(
                            EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          leading: const Icon(LucideIcons.search),
                          trailing: _searchTermTEC.text.isNotEmpty
                              ? [
                                  IconButton(
                                    icon: const Icon(LucideIcons.x),
                                    onPressed: () {
                                      _searchTermTEC.clear();
                                      setState(() {});
                                    },
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                  if (showCompareSheet)
                    TeamCompareSheet(controller: _sheetController),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class TeamCompareSheet extends ConsumerWidget {
  final DraggableScrollableController controller;

  const TeamCompareSheet({super.key, required this.controller});

  double pxToSheetFraction(double pixels, double availableHeight) {
    return pixels / availableHeight;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectedTeams = ref.watch(collectedTeamsProvider);
    final isDragging = ref.watch(isDraggingProvider);
    final isCompareSheetVisible = ref.watch(compareSheetVisibleProvider);
    final theme = Theme.of(context);

    if (collectedTeams.isEmpty && !isCompareSheetVisible) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;

        // Pixel-based heights
        const collapsedHeight = _TeamLookupPageState._collapsedSheetHeight;
        const expandedHeight = _TeamLookupPageState._expandedSheetHeight;

        final minSize = (collapsedHeight / availableHeight).clamp(0.0, 1.0);

        final maxSize = (expandedHeight / availableHeight).clamp(minSize, 1.0);

        return DraggableScrollableSheet(
          controller: controller,
          initialChildSize: minSize,
          minChildSize: minSize,
          maxChildSize: maxSize,
          snap: true,

          builder: (context, scrollController) {
            return DragTarget<String>(
              onAcceptWithDetails: (details) {
                final teamKey = details.data;
                final currentList = ref.read(collectedTeamsProvider);

                if (!currentList.contains(teamKey)) {
                  HapticFeedback.mediumImpact();

                  ref.read(collectedTeamsProvider.notifier).state = [
                    teamKey,
                    ...currentList,
                  ];
                }
              },

              builder: (context, candidateData, rejectedData) {
                final isHovering = candidateData.isNotEmpty;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  decoration: BoxDecoration(
                    color: isHovering
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHigh,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),

                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              height: 4,
                              width: 32,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurfaceVariant,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),

                            const SizedBox(height: 12),

                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: isDragging
                                  ? Row(
                                      key: const ValueKey('dragging'),
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          LucideIcons.arrowDownToLine,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Drop to add to compare',

                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    )
                                  : Padding(
                                      key: const ValueKey('resting'),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Compare',
                                                style:
                                                    theme.textTheme.titleMedium,
                                              ),
                                              Text(
                                                '${collectedTeams.length} team${collectedTeams.length == 1 ? '' : 's'}',
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          if (collectedTeams.isNotEmpty)
                                            FilledButton.tonalIcon(
                                              onPressed: () {
                                                HapticFeedback.lightImpact();
                                                ref
                                                        .read(
                                                          collectedTeamsProvider
                                                              .notifier,
                                                        )
                                                        .state =
                                                    [];

                                                controller.animateTo(
                                                  minSize,
                                                  duration: const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  curve: Curves.easeOutBack,
                                                );

                                                Future.delayed(
                                                  const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  () {
                                                    ref
                                                            .read(
                                                              compareSheetVisibleProvider
                                                                  .notifier,
                                                            )
                                                            .state =
                                                        false;
                                                  },
                                                );
                                              },

                                              icon: const Icon(
                                                LucideIcons.trash2,
                                                size: 18,
                                              ),

                                              label: const Text('Clear'),
                                            ),
                                        ],
                                      ),
                                    ),
                            ),

                            const SizedBox(height: 8),
                            const Divider(),
                          ],
                        ),
                      ),

                      SliverPadding(
                        padding: const EdgeInsets.all(16.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),

                              child: TeamCard(teamKey: collectedTeams[index]),
                            );
                          }, childCount: collectedTeams.length),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class SortByFieldItem extends StatefulWidget {
  final double total;
  final VoidCallback? onAddNew;

  const SortByFieldItem({super.key, required this.total, this.onAddNew});

  @override
  State<StatefulWidget> createState() {
    return SortByFieldItemState();
  }
}

class SortByFieldItemState extends State<SortByFieldItem> {
  String sectionId = '';
  String dataId = '';

  List<DropdownMenuEntry<String>> generateDropdownMenuItems(List<String> list) {
    List<DropdownMenuEntry<String>> finalList = [];
    for (var item in list) {
      finalList.add(DropdownMenuEntry(value: item, label: item));
    }
    return finalList;
  }

  List<String> sectionIdToDataPointsList(String sectionId) {
    switch (sectionId) {
      case 'auto':
        return kAutoDataList;
      case 'tele':
        return kTeleDataList;
      case 'endgame':
        return kEndgameDataList;
      default:
        return kTeleDataList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          DropdownMenu<String>(
            dropdownMenuEntries: generateDropdownMenuItems(kSectionsList),
            onSelected: (item) {
              if (item != null) {
                sectionId = item;
              }
            },
          ),
          DropdownMenu<String>(
            dropdownMenuEntries: generateDropdownMenuItems(
              sectionIdToDataPointsList(sectionId),
            ),
            onSelected: (item) {
              if (item != null) {
                dataId = item;
              }
            },
          ),
          SizedBox.shrink(child: TextField(onChanged: (text) {})),
        ],
      ),
      trailing: ElevatedButton(
        onPressed: () {
          widget.onAddNew;
        },
        child: Icon(LucideIcons.circlePlus),
      ),
    );
  }
}
