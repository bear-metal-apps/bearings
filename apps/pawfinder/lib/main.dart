import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:libkoala/providers/api_provider.dart';
import 'package:libkoala/providers/auth_provider.dart';
import 'package:pawfinder/data/local_data.dart';
import 'package:pawfinder/pages/flow/config_page.dart';
import 'package:pawfinder/pages/flow/match_select_page.dart';
import 'package:pawfinder/pages/flow/scout_page.dart';
import 'package:pawfinder/pages/flow/scouting_shell.dart';
import 'package:pawfinder/pages/flow/settings_page.dart';
import 'package:pawfinder/pages/flow/strat_shell.dart';
import 'package:pawfinder/pages/match_page.dart';
import 'package:pawfinder/pages/provisioning_page.dart';
import 'package:pawfinder/pages/splash_screen.dart';
import 'package:pawfinder/pages/strat.dart';
import 'package:pawfinder/providers/brightness_provider.dart';
import 'package:pawfinder/services/device_auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadStorage();
  runApp(
    ProviderScope(
      overrides: [
        // use client_credentials token instead of PKCE user auth.
        honeycombClientProvider.overrideWith((ref) {
          final deviceAuth = ref.watch(deviceAuthServiceProvider);
          return HoneycombClient(ref, tokenOverride: deviceAuth.getAccessToken);
        }),
      ],
      child: const MyApp(),
    ),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final authStatus = ref.watch(authStatusProvider.notifier);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authStatus,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/provision',
        builder: (context, state) => const ProvisioningPage(),
      ),
      GoRoute(
        path: '/config',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: ConfigPage()),
        routes: [
          GoRoute(
            path: 'settings',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsPage()),
          ),
        ],
      ),
      GoRoute(
        path: '/scout',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: ScoutPage()),
      ),
      GoRoute(
        path: '/match-select',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: MatchSelectPage()),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ScoutingShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/match/auto',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const MatchPage(index: 0),
            ),
          ),
          GoRoute(
            path: '/match/tele',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const MatchPage(index: 1),
            ),
          ),
          GoRoute(
            path: '/match/end',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const MatchPage(index: 2),
            ),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) {
          return StratShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/strat',
            builder: (context, state) => const StratPage(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final auth = ref.read(authStatusProvider);
      final location = state.matchedLocation;

      // splash while authing
      if (auth == AuthStatus.authenticating) {
        return location == '/splash' ? null : '/splash';
      }

      // go to provision page if device is not provisioned
      if (auth == AuthStatus.unauthenticated) {
        return location == '/provision' ? null : '/provision';
      }

      // if on provision/splash and authed then go to config
      if (auth == AuthStatus.authenticated) {
        if (location == '/provision' || location == '/splash') {
          return '/config';
        }
      }

      return null;
    },
  );
});

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deviceAuthServiceProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Pawfinder',
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: ref.watch(brightnessNotifierProvider),
        ),
      ),
    );
  }
}
