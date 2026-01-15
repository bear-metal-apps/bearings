import 'dart:convert';
import 'dart:io';

import 'package:beariscope_scouter/pages/schedule.dart';
import 'package:beariscope_scouter/pages/strat.dart';
import 'package:beariscope_scouter/custom_widgets/nav_bar.dart';
import 'package:beariscope_scouter/page/match.dart';
import 'package:beariscope_scouter/page/schedule.dart';
import 'package:beariscope_scouter/page/strat.dart';
import 'package:beariscope_scouter/page/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'page/match_stages/auto_page.dart';
import 'page/match_stages/end_page.dart';
import 'page/match_stages/tele_page.dart';
import 'custom_widgets/match_page.dart';
import 'custom_widgets/nav_bar.dart';
import 'pages/match.dart';
import 'pages/match_stages/auto_page.dart';
import 'pages/match_stages/end_page.dart';
import 'pages/match_stages/tele_page.dart';
import 'pages/user.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp()
    )
  );
}

Future<Map<String, dynamic>> loadUiConfig() async {
  final jsonString = await rootBundle.loadString('resources/ui_creator.json');
  return jsonDecode(jsonString);
}
final List<FutureBuilder> matchPages = [
  FutureBuilder(
    future: loadUiConfig(),
    builder: (context, snapshot) {
      if (snapshot.hasData && snapshot.data != null) {
        return MatchWidget(
          json: snapshot.data!,
          pageIndex: 0,
        );
      } else if (snapshot.hasError) {
        return Center(child: Text("404 - UI not loaded"));
      }
      return LoadingAnimationWidget.staggeredDotsWave(
        color: Colors.greenAccent,
        size: 20,
      );
    },
  ),
  FutureBuilder(
    future: loadUiConfig(),
    builder: (context, snapshot) {
      if (snapshot.hasData && snapshot.data != null) {
        return MatchWidget(
          json: snapshot.data!,
          pageIndex: 1,
        );
      } else if (snapshot.hasError) {
        return Center(child: Text("404 - UI not loaded"));
      }
      return LoadingAnimationWidget.staggeredDotsWave(
        color: Colors.greenAccent,
        size: 20,
      );
    },
  ),
  FutureBuilder(
    future: loadUiConfig(),
    builder: (context, snapshot) {
      if (snapshot.hasData && snapshot.data != null) {
        return MatchWidget(
          json: snapshot.data!,
          pageIndex: 2,
        );
      } else if (snapshot.hasError) {
        return Center(child: Text("404 - UI not loaded"));
      }
      return LoadingAnimationWidget.staggeredDotsWave(
        color: Colors.greenAccent,
        size: 20,
      );
    },
  ),
];

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
