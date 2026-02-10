import 'package:beariscope_scouter/custom_widgets/match_page.dart';
import 'package:beariscope_scouter/data/local_data.dart';
import 'package:beariscope_scouter/pages/flow/config_page.dart';
import 'package:beariscope_scouter/pages/flow/match_select_page.dart';
import 'package:beariscope_scouter/pages/flow/scout_page.dart';
import 'package:beariscope_scouter/pages/flow/scouting_shell.dart';
import 'package:beariscope_scouter/pages/flow/settings_page.dart';
import 'package:beariscope_scouter/pages/flow/strat_shell.dart';
import 'package:beariscope_scouter/pages/splash_screen.dart';
import 'package:beariscope_scouter/pages/strat.dart';
import 'package:beariscope_scouter/pages/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:libkoala/providers/auth_provider.dart';
import 'package:libkoala/providers/device_info_provider.dart';

void main() {
  loadHive();
  runApp(
    ProviderScope(
      overrides: [
        auth0ConfigProvider.overrideWith((ref) {
          return const Auth0Config(
            domain: 'bearmetal2046.us.auth0.com',
            clientId: 'fKM2govQm439bV3jL4lCmtA0yjO9tgsO',
            audience: 'ORLhqJbHiTfgdF3Q8hqIbmdwT1wTkkP7',
            redirectUris: {
              DeviceOS.ios: 'org.tahomarobotics.beariscope_scouter://callback',
              DeviceOS.macos:
                  'org.tahomarobotics.beariscope_scouter://callback',
              DeviceOS.android:
                  'org.tahomarobotics.beariscope_scouter://callback',
              DeviceOS.windows: 'http://localhost:4000/auth',
              DeviceOS.linux: 'http://localhost:4000/auth',
            },
            storageKeyPrefix: 'beariscope_',
          );
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
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
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
            builder: (context, state) => Stack(children: matchPages[0]),
          ),
          GoRoute(
            path: '/match/tele',
            builder: (context, state) => Stack(children: matchPages[1]),
          ),
          GoRoute(
            path: '/match/end',
            builder: (context, state) => Stack(children: matchPages[2]),
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

      // go to welcome if not authed
      if (auth == AuthStatus.unauthenticated) {
        return location == '/welcome' ? null : '/welcome';
      }

      // if on welcome/splash and authed then go to config
      if (auth == AuthStatus.authenticated) {
        if (location == '/welcome' || location == '/splash') {
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
      ref.read(authProvider).trySilentLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    loadUI(context);

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Pawfinder',
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}
