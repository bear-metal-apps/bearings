import 'dart:convert';

import 'package:beariscope_scouter/data/ui_json_serialization.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'match_config_provider.g.dart';

@Riverpod(keepAlive: true)
Future<MatchConfig> matchConfig(Ref ref) async {
  final json = jsonDecode(
    await rootBundle.loadString('resources/ui_creator.json'),
  );
  return MatchConfig.fromJson(json);
}
