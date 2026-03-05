
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
import 'package:pawfinder/pages/flow/strat_shell.dart';
import 'package:pawfinder/pages/flow/settings_page.dart';
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
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/provision',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProvisioningPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            );
          },
        ),
      ),
      GoRoute(
        path: '/config',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ConfigPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            );
          },
        ),
        routes: [
          GoRoute(
            path: 'settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  )),
                  child: child,
                );
              },
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/scout',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ScoutPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ),
                ),
                child: child,
              ),
            );
          },
        ),
      ),
      GoRoute(
        path: '/match-select',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MatchSelectPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            );
          },
        ),
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
          GoRoute(
            path: '/match/settings',
            builder: (context, state) => const SettingsPage(),
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
          GoRoute(
            path: '/strat/settings',
            builder: (context, state) => const SettingsPage(),
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
    final brightness = ref.watch(brightnessNotifierProvider);

    return MaterialApp.router(
      title: 'Pawfinder',
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 0, 76, 255),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 26, 255),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: brightness == Brightness.light ? ThemeMode.light : ThemeMode.dark,
    );
  }
}
