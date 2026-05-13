import 'package:beariscope/pages/settings/appearance_settings_page.dart';
import 'package:beariscope/providers/current_event_provider.dart';
import 'package:beariscope/providers/scouting_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:services/providers/auth_provider.dart';
import 'package:services/providers/connectivity_provider.dart';
import 'package:services/widgets/profile_picture.dart';

class TopLevelPageAppBarActions extends StatelessWidget {
  const TopLevelPageAppBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 8),
        _EventSelectorAction(),
        SizedBox(width: 12),
        _ProfilePictureMenuAction(),
      ],
    );
  }
}

class _EventSelectorAction extends ConsumerWidget {
  const _EventSelectorAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentEventKey = ref.watch(currentEventProvider);
    final eventsAsync = ref.watch(teamEventsProvider);
    final selectedEvent = eventsAsync.maybeWhen(
      data: (events) => events.firstWhere(
        (event) => event.key == currentEventKey,
        orElse: () => EventOption.current(currentEventKey),
      ),
      orElse: () => EventOption.current(currentEventKey),
    );

    return MenuTheme(
      data: MenuThemeData(
        style: MenuStyle(
          elevation: const WidgetStatePropertyAll(8.0),
          backgroundColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
      child: MenuAnchor(
        animated: true,
        alignmentOffset: const Offset(0, 8),
        builder: (context, controller, child) {
          return FilledButton.tonalIcon(
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            label: Text(selectedEvent.displayShortName),
            icon: Icon(
              controller.isOpen
                  ? Symbols.unfold_less_rounded
                  : Symbols.unfold_more_rounded,
            ),
            iconAlignment: IconAlignment.end,
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              foregroundColor: Theme.of(
                context,
              ).colorScheme.onTertiaryContainer,
              padding: const EdgeInsets.only(left: 16, right: 12),
            ),
          );
        },
        menuChildren: eventsAsync.when(
          data: (events) => [
            for (final e in eventPickerOptions(events, currentEventKey))
              MenuItemButton(
                style: const ButtonStyle(
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
                leadingIcon: Icon(e.leadingIcon, size: 20),
                trailingIcon: e.key == currentEventKey
                    ? Icon(
                        Symbols.check_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : const SizedBox(width: 20),
                onPressed: () {
                  ref.read(currentEventProvider.notifier).setEventKey(e.key);
                },
                child: Text(e.displayName),
              ),
          ],
          loading: () => [
            const MenuItemButton(
              onPressed: null,
              style: ButtonStyle(
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
              leadingIcon: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              child: Text('Loading events...'),
            ),
          ],
          error: (e, s) => [
            MenuItemButton(
              style: const ButtonStyle(
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
              onPressed: () => ref.invalidate(teamEventsProvider),
              leadingIcon: const Icon(Symbols.error_rounded, size: 20),
              child: const Text('Failed to load events. Retry?'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePictureMenuAction extends ConsumerStatefulWidget {
  const _ProfilePictureMenuAction();

  @override
  ConsumerState<_ProfilePictureMenuAction> createState() =>
      _ProfilePictureMenuActionState();
}

class _ProfilePictureMenuActionState
    extends ConsumerState<_ProfilePictureMenuAction> {
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final isOnline = switch (ref.watch(connectivityProvider)) {
      AsyncData(:final value) => value,
      _ => true,
    };
    final themeMode = ref.watch(themeModeProvider);

    return MenuTheme(
      data: MenuThemeData(
        style: MenuStyle(
          elevation: const WidgetStatePropertyAll(8.0),
          backgroundColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
      child: MenuAnchor(
        animated: true,
        alignmentOffset: const Offset(0, 8),
        builder: (context, controller, child) {
          return InkWell(
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            borderRadius: BorderRadius.circular(999),
            child: const ProfilePicture(size: 16),
          );
        },
        menuChildren: _buildProfileMenuChildren(
          context: context,
          isOnline: isOnline,
          themeMode: themeMode,
        ),
      ),
    );
  }

  List<Widget> _buildProfileMenuChildren({
    required BuildContext context,
    required bool isOnline,
    required ThemeMode themeMode,
  }) {
    return [
      MenuItemButton(
        closeOnActivate: false,
        style: const ButtonStyle(
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        leadingIcon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isRefreshing
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  isOnline ? Symbols.sync_rounded : Symbols.cloud_off_rounded,
                  key: const ValueKey('icon'),
                  size: 20,
                ),
        ),
        onPressed: isOnline && !_isRefreshing
            ? () {
                _doRefresh();
              }
            : null,
        child: Text(
          _isRefreshing
              ? 'Syncing...'
              : isOnline
              ? 'Sync Scouting Data'
              : 'Sync Unavailable (Offline)',
        ),
      ),
      const Divider(height: 16),
      MenuItemButton(
        style: const ButtonStyle(
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        leadingIcon: const Icon(Symbols.qr_code_rounded, size: 20),
        onPressed: () => context.push('/device_provisioning'),
        child: const Text('Provision Device'),
      ),
      MenuItemButton(
        style: const ButtonStyle(
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        leadingIcon: const Icon(Symbols.export_notes_rounded, size: 20),
        onPressed: () => context.push('/export'),
        child: const Text('Export Data'),
      ),
      const Divider(height: 16),
      MenuItemButton(
        style: const ButtonStyle(
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        leadingIcon: const Icon(Symbols.settings_rounded, size: 20),
        onPressed: () => context.push('/settings'),
        child: const Text('Settings'),
      ),
      SubmenuButton(
        style: const ButtonStyle(
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        animated: true,
        menuStyle: MenuStyle(
          elevation: const WidgetStatePropertyAll(8.0),
          backgroundColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        submenuIcon: const WidgetStatePropertyAll(
          Icon(Symbols.chevron_right_rounded, size: 16),
        ),
        leadingIcon: const Icon(Symbols.dark_mode_rounded, size: 20),
        menuChildren: [
          for (final mode in ThemeMode.values)
            MenuItemButton(
              style: const ButtonStyle(
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
              trailingIcon: mode == themeMode
                  ? Icon(
                      Symbols.check_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : const SizedBox(width: 20),
              onPressed: () async {
                await ref.read(themeModeProvider.notifier).setThemeMode(mode);
              },
              leadingIcon: Icon(switch (mode) {
                ThemeMode.light => Symbols.light_mode_rounded,
                ThemeMode.dark => Symbols.dark_mode_rounded,
                ThemeMode.system => Symbols.routine_rounded,
              }, size: 20),
              child: Text(switch (mode) {
                ThemeMode.light => 'Light',
                ThemeMode.dark => 'Dark',
                ThemeMode.system => 'System',
              }),
            ),
        ],
        child: const Text('Theme'),
      ),
      const Divider(height: 16),
      MenuItemButton(
        closeOnActivate: false,
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          foregroundColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.error,
          ),
        ),
        leadingIcon: Icon(
          Symbols.logout_rounded,
          size: 20,
          color: Theme.of(context).colorScheme.error,
        ),
        onPressed: () async {
          final confirmed =
              await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              ) ??
              false;

          if (confirmed && context.mounted) {
            final auth = await ref.read(authProvider.future);
            await auth.logout(federated: true);
          }
        },
        child: const Text('Sign Out'),
      ),
    ];
  }

  Future<void> _doRefresh() async {
    setState(() => _isRefreshing = true);
    try {
      await ref.read(scoutingDataProvider.notifier).refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }
}
