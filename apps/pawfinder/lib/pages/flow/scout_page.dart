import 'package:beariscope_scouter/models/scouting_session.dart';
import 'package:beariscope_scouter/providers/scouting_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ScoutPage extends ConsumerStatefulWidget {
  const ScoutPage({super.key});

  @override
  ConsumerState<ScoutPage> createState() => _ScoutPageState();
}

class _ScoutPageState extends ConsumerState<ScoutPage> {
  String _searchQuery = '';
  Scout? _selectedScout;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(scoutingSessionProvider);
      if (mounted) {
        setState(() {
          _selectedScout = session.scout;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scoutsAsync = ref.watch(scoutsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/config'),
        ),
        title: const Text('Select Scout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                SearchBar(
                  hintText: 'Search scouts...',
                  elevation: WidgetStateProperty.all(0.0),
                  shape: WidgetStateProperty.all(
                    StadiumBorder(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 1,
                      ),
                    ),
                  ),
                  padding: WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  leading: const Icon(Icons.search),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 32),

                Expanded(
                  child: scoutsAsync.when(
                    data: (scouts) {
                      final filtered = scouts.where((s) {
                        return s.name.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        );
                      }).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            scouts.isEmpty
                                ? 'No scouts found'
                                : 'No scouts match "$_searchQuery"',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 8);
                        },
                        itemBuilder: (context, index) {
                          final scout = filtered[index];
                          final isSelected = _selectedScout == scout;
                          return ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 4),
                            leading: CircleAvatar(
                              backgroundColor: isSelected
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primaryFixedDim
                                  : Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                              child: Text(
                                scout.name.isNotEmpty
                                    ? scout.name[0].toUpperCase()
                                    : '?',
                              ),
                            ),
                            title: Text(scout.name),
                            selected: isSelected,
                            selectedTileColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            shape: StadiumBorder(),
                            onTap: () {
                              setState(() => _selectedScout = scout);
                              ref
                                  .read(scoutingSessionProvider.notifier)
                                  .setScout(scout);
                            },
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Failed to load scouts',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => ref.invalidate(scoutsProvider),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _selectedScout != null
                        ? () {
                            ref
                                .read(scoutingSessionProvider.notifier)
                                .setScout(_selectedScout!);
                            context.go('/match-select');
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
