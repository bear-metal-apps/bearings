import 'dart:convert';
import 'dart:io';

import 'package:beariscope_scouter/data/local_data.dart';
import 'package:beariscope_scouter/pages/schedule.dart';
import 'package:beariscope_scouter/pages/strat.dart';
import 'package:beariscope_scouter/custom_widgets/nav_bar.dart';
import 'package:beariscope_scouter/pages/match.dart';
import 'package:beariscope_scouter/pages/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'custom_widgets/match_page.dart';

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
            title: "Current Page",
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
          ShellRoute(
            builder: (context, state, page) {
              return MatchNavBar(page: page, router: router);
            },
            routes: [
              GoRoute(
                path: '/Match',
                builder: (context, state) => const MatchPage(),
                routes: [
                  GoRoute(
                    path: 'Auto',
                    builder: (context, state) => matchPages[0]
                  ),
                  GoRoute(
                    path: 'Tele',
                    builder: (context, state) => matchPages[1]
                  ),
                  GoRoute(
                    path: 'End',
                    builder: (context, state) => matchPages[2]
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Paw-Finder',
      routerConfig: router,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}
