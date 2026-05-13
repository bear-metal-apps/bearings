import 'package:beariscope/pages/scout_audit/scout_audit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:services/providers/permissions_provider.dart';

class _NavItem {
  final String route;
  final IconData icon;
  final String label;
  final List<String> requiredPermissions;
  final int? Function(WidgetRef ref)? badgeCountBuilder;

  const _NavItem({
    required this.route,
    required this.icon,
    required this.label,
    this.requiredPermissions = const [],
    this.badgeCountBuilder,
  });

  bool isVisibleFor(PermissionChecker? permissionChecker) {
    return requiredPermissions.every(
      (permission) => permissionChecker?.hasPermission(permission) ?? false,
    );
  }

  int? badgeCount(WidgetRef ref) => badgeCountBuilder?.call(ref);
}

class MainView extends ConsumerWidget {
  final Widget child;

  const MainView({super.key, required this.child});

  static final List<_NavItem> _navItems = [
    const _NavItem(
      route: '/up_next',
      icon: Symbols.event_rounded,
      label: 'Up Next',
    ),
    const _NavItem(
      route: '/team_lookup',
      icon: Symbols.smart_toy_rounded,
      label: 'Teams',
    ),
    const _NavItem(
      route: '/scout_audit',
      icon: Symbols.fact_check_rounded,
      label: 'Audit',
      badgeCountBuilder: _auditIssueCount,
    ),
    const _NavItem(
      route: '/pits_scouting',
      icon: Symbols.build_rounded,
      label: 'Pits',
      requiredPermissions: [PermissionKey.pitsUpload, PermissionKey.pitsRead],
    ),
  ];

  List<_NavItem> _visibleNavItems(PermissionChecker? permissionChecker) {
    return [
      for (final item in _navItems)
        if (item.isVisibleFor(permissionChecker)) item,
    ];
  }

  int _selectedIndexFor(BuildContext context, List<_NavItem> items) {
    final location = GoRouterState.of(context).uri.toString();
    return items.indexWhere((n) => location.startsWith(n.route));
  }

  void _onDestinationSelected(
    BuildContext context,
    int index,
    List<_NavItem> items,
  ) {
    if (index < 0 || index >= items.length) return;
    context.go(items[index].route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final permissionChecker = ref.watch(permissionCheckerProvider);
        final visibleNavItems = _visibleNavItems(permissionChecker);
        final selectedIndex = _selectedIndexFor(context, visibleNavItems);

        final authMeLoaded = ref.watch(authMeProvider).hasValue;
        final hasNoPermissions =
            authMeLoaded &&
            permissionChecker != null &&
            permissionChecker.permissions.isEmpty;

        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hasNoPermissions) const _NoPermissionsBanner(),
              Expanded(child: child),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex == -1 ? 0 : selectedIndex,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) =>
                _onDestinationSelected(context, index, visibleNavItems),
            destinations: [
              for (final item in visibleNavItems)
                NavigationDestination(
                  icon: _NavTargetIcon(
                    icon: item.icon,
                    badgeCount: item.badgeCount(ref),
                  ),
                  selectedIcon: _NavTargetIcon(
                    icon: item.icon,
                    badgeCount: item.badgeCount(ref),
                  ),
                  tooltip: '',
                  label: item.label,
                ),
            ],
          ),
        );
      },
    );
  }
}

int? _auditIssueCount(WidgetRef ref) {
  final snapshot = ref
      .watch(scoutAuditSnapshotProvider)
      .maybeWhen(data: (snapshot) => snapshot, orElse: () => null);
  if (snapshot == null) return null;

  final count =
      snapshot.incompleteMatches.length +
      snapshot.notInTba.length +
      snapshot.duplicates.length +
      snapshot.incorrect.length;

  return count > 0 ? count : null;
}

class _NavTargetIcon extends StatelessWidget {
  const _NavTargetIcon({required this.icon, this.badgeCount});

  final IconData icon;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final label = badgeCount == null
        ? null
        : badgeCount! > 99
        ? '99+'
        : badgeCount.toString();

    if (label == null) {
      return Icon(icon);
    }
    return Badge(label: Text(label), child: Icon(icon));
  }
}

class _NoPermissionsBanner extends StatelessWidget {
  const _NoPermissionsBanner();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.errorContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Symbols.warning_rounded,
                color: colorScheme.onErrorContainer,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You don\'t have any permissions yet and won\'t be able to use the app. Ask an Apps lead or Executive to give you access.',
                  style: TextStyle(
                    color: colorScheme.onErrorContainer,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
