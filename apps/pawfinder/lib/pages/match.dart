import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
