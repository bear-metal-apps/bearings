import 'package:flutter/material.dart';

class TeamColors {
  final Color primary;
  final Color? secondary;
  final bool verified;

  TeamColors({required this.primary, this.secondary, required this.verified});

  factory TeamColors.fromJson(Map<String, dynamic> json) {
    return TeamColors(
      primary: _hexToColor(json['primaryHex'] as String),
      secondary: json['secondaryHex'] != null
          ? _hexToColor(json['secondaryHex'] as String)
          : null,
      verified: json['verified'] as bool,
    );
  }

  static Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}

class Team {
  final String key;
  final int number;
  final String name;
  final TeamColors? colors;

  Team({
    required this.key,
    required this.number,
    required this.name,
    this.colors,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    // extract number (try multiple field names and types)
    dynamic numberRaw =
        json['team_number'] ?? json['teamNumber'] ?? json['number'];
    int number = 0;
    if (numberRaw is int) {
      number = numberRaw;
    } else if (numberRaw is String) {
      number = int.tryParse(numberRaw) ?? 0;
    }

    // extract key (try multiple names, or generate from number)
    String? keyRaw = (json['team_key'] ?? json['team'] ?? json['key'])
        ?.toString();
    String key = (keyRaw != null && keyRaw.isNotEmpty) ? keyRaw : 'frc$number';

    // extract name
    String name =
        (json['nickname'] ??
                json['team_name'] ??
                json['name'] ??
                'Unknown Team')
            .toString();

    final colorsJson = json['colors'];

    return Team(
      key: key,
      number: number,
      name: name,
      colors: colorsJson != null
          ? TeamColors.fromJson(Map<String, dynamic>.from(colorsJson as Map))
          : null,
    );
  }
}
