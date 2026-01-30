import 'dart:convert';
import 'dart:io';

import 'package:beariscope_scouter/data/local_data.dart';
import 'package:beariscope_scouter/pages/schedule.dart';
import 'package:beariscope_scouter/pages/strat.dart';
import 'package:beariscope_scouter/custom_widgets/nav_bar.dart';
import 'package:beariscope_scouter/pages/match.dart';
import 'package:beariscope_scouter/pages/schedule.dart';
import 'package:beariscope_scouter/pages/strat.dart';
import 'package:beariscope_scouter/pages/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'custom_widgets/match_page.dart';
import 'custom_widgets/nav_bar.dart';
import 'pages/match.dart';
import 'pages/match_stages/auto_page.dart';
import 'pages/match_stages/end_page.dart';
import 'pages/match_stages/tele_page.dart';
import 'pages/user.dart';

void main() {
  loadHive();
  runApp(
    const ProviderScope(
      child: MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GoRouter router = GoRouter(
    initialLocation: "/",
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return NavBar(
            page: child,
            appBar: Text("Current Page"),
            router: MyApp.router,
          );
        },
        routes: [
          GoRoute(path: '/User', builder: (context, state) => const UserPage()),
          GoRoute(
            path: '/Strat',
            builder: (context, state) => const StratPage(),
          ),
          GoRoute(path: '/', builder: (context, state) => const SchedulePage()),
        ],
      ),
      ShellRoute(
        builder: (context, state, page) {
          final MatchInformation matchInformation =
              state.extra is MatchInformation
              ? state.extra as MatchInformation
              : MatchInformation();
          return MatchNavBar(
            page: page,
            router: router,
            matchInformation: matchInformation,
          );
        },
        routes: [
          GoRoute(
            path: '/Match',
            builder: (context, state) => const MatchPage(),
            routes: [
              GoRoute(
                path: 'Auto',
                builder: (context, state) {
                  return Stack(children: matchPages[0]);
                },
              ),
              GoRoute(
                path: 'Tele',
                builder: (context, state) => Stack(children: matchPages[1]),
              ),
              GoRoute(
                path: 'End',
                builder: (context, state) => Stack(children: matchPages[2]),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    loadUI(context);
    return MaterialApp.router(
      title: 'Paw-Finder',
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}
