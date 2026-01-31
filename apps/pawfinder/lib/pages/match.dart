import 'dart:convert';

import 'package:beariscope_scouter/custom_widgets/match_page.dart';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path/path.dart';

import '../custom_widgets/match_page.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MatchPage extends ConsumerStatefulWidget {
  const MatchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return MatchPageState();
  }
}

class MatchPageState extends ConsumerState<MatchPage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Match Page"));
  }
}

Future<Map<String, dynamic>> loadUiConfig() async {
  final jsonString = await rootBundle.loadString('resources/ui_creator.json');
  return jsonDecode(jsonString);
}
