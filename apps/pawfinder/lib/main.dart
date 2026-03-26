import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawfinder/custom_widgets/page_transitions.dart';
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
import 'package:pawfinder/pages/welcome_page.dart';
import 'package:pawfinder/providers/app_provider.dart';
import 'package:pawfinder/services/device_auth_service.dart';
import 'package:pawfinder/services/scout_upload_service.dart';
import 'package:services/providers/api_provider.dart';
import 'package:services/providers/auth_provider.dart';
import 'package:services/providers/connectivity_provider.dart';
import 'package:services/services.dart';
import 'package:core/core.dart' show DeviceOS;

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
        auth0ConfigProvider.overrideWith((ref) {
          return const Auth0Config(
            domain: 'bearmetal2046.us.auth0.com',
            clientId: 'ORLhqJbHiTfgdF3Q8hqIbmdwT1wTkkP7',
            audience: 'ORLhqJbHiTfgdF3Q8hqIbmdwT1wTkkP7',
            redirectUris: {
              DeviceOS.ios: 'io.github.bearmetal2046.pawfinder://callback',
              DeviceOS.macos: 'io.github.bearmetal2046.pawfinder://callback',
              DeviceOS.android: 'io.github.bearmetal2046.pawfinder://callback',
              DeviceOS.web: 'https://scout.bearmet.al/auth.html',
              DeviceOS.windows: 'http://localhost:4000/auth',
              DeviceOS.linux: 'http://localhost:4000/auth',
            },
            storageKeyPrefix: 'pawfinder_',
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
    initialLocation: '/welcome',
    refreshListenable: authStatus,
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
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
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const ScoutPage(),
        ),
      ),
      GoRoute(
        path: '/match-select',
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const MatchSelectPage(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ScoutingShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/match/auto',
            pageBuilder: (context, state) => MatchSectionTransitionPage(
              key: state.pageKey,
              child: const MatchPage(index: 0),
            ),
          ),
          GoRoute(
            path: '/match/tele',
            pageBuilder: (context, state) => MatchSectionTransitionPage(
              key: state.pageKey,
              child: const MatchPage(index: 1),
            ),
          ),
          GoRoute(
            path: '/match/end',
            pageBuilder: (context, state) => MatchSectionTransitionPage(
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

      // stay on welcome/provision if device is not provisioned
      if (auth == AuthStatus.unauthenticated) {
        if (location == '/welcome' || location == '/provision') return null;
        return '/welcome';
      }

      // if on welcome/provision/splash and authed then go to config
      if (auth == AuthStatus.authenticated) {
        if (location == '/welcome' || location == '/provision' || location == '/splash') {
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
  ProviderSubscription<AsyncValue<bool>>? _connectivitySubscription;
  bool? _wasOnline;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deviceAuthServiceProvider).initialize();
    });
    _connectivitySubscription = ref.listenManual<AsyncValue<bool>>(
      connectivityProvider,
      (previous, next) {
        final currentOnline = next.value;
        final previousOnline = previous?.value ?? _wasOnline;
        _wasOnline = currentOnline;
        if (currentOnline == true && previousOnline != true) {
          unawaited(ref.read(scoutUploadServiceProvider).drainIfOnline());
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _connectivitySubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final usePapyrusFont = ref.watch(papyrusFontProvider);

    return MaterialApp.router(
      title: 'Pawfinder',
      routerConfig: router,
      theme: ThemeData(
        fontFamily: usePapyrusFont
            ? 'Papyrus'
            : GoogleFonts.googleSansFlex().fontFamily,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 221, 255),
          brightness: ref.watch(brightnessNotifierProvider),
        ),
      ),
    );
  }
}
