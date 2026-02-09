import 'package:beariscope_scouter/data/local_data.dart';
import 'package:beariscope_scouter/pages/schedule.dart';
import 'package:beariscope_scouter/pages/splash_screen.dart';
import 'package:beariscope_scouter/pages/strat.dart';
import 'package:beariscope_scouter/custom_widgets/nav_bar.dart';
import 'package:beariscope_scouter/pages/match.dart';
import 'package:beariscope_scouter/pages/user.dart';
import 'package:beariscope_scouter/custom_widgets/match_page.dart';
import 'package:beariscope_scouter/pages/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:libkoala/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
              DeviceOS.macos: 'org.tahomarobotics.beariscope_scouter://callback',
              DeviceOS.android: 'org.tahomarobotics.beariscope_scouter://callback',
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
      ShellRoute(
        builder: (context, state, child) {
          return NavBar(page: child, appBar: const Text("Current Page"));
        },
        routes: [
          GoRoute(path: '/user', builder: (context, state) => const UserPage()),
          GoRoute(
            path: '/strat',
            builder: (context, state) => const StratPage(),
          ),
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const SchedulePage(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, page) {
          final MatchInformation matchInformation =
              state.extra is MatchInformation
              ? state.extra as MatchInformation
              : MatchInformation();
          return MatchNavBar(page: page, matchInformation: matchInformation);
        },
        routes: [
          GoRoute(
            path: '/match',
            builder: (context, state) => const MatchPage(),
            routes: [
              GoRoute(
                path: 'auto',
                builder: (context, state) => Stack(children: matchPages[0]),
              ),
              GoRoute(
                path: 'tele',
                builder: (context, state) => Stack(children: matchPages[1]),
              ),
              GoRoute(
                path: 'end',
                builder: (context, state) => Stack(children: matchPages[2]),
              ),
            ],
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

      // if on welcome and authed then leave
      if (auth == AuthStatus.authenticated) {
        if (location == '/welcome' || location == '/splash') {
          return '/schedule';
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}
