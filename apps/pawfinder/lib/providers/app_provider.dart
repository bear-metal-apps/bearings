import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawfinder/data/local_data.dart';

const _colorSchemePrefKey = 'color_scheme';

class BrightnessProvider extends Notifier<Brightness> {
  @override
  Brightness build() => Brightness.light;

  void changeBrightness(bool value) =>
      value ? state = Brightness.dark : state = Brightness.light;
}

final brightnessNotifierProvider =
    NotifierProvider<BrightnessProvider, Brightness>(BrightnessProvider.new);

enum AppColorScheme {
  yellow('Bear Metal Yellow', Color.fromARGB(255, 255, 214, 10)),
  cyan('Chill Out Cyan', Color.fromARGB(255, 0, 221, 255)),
  emerald('Jack in the Bot Emerald', Color.fromARGB(255, 24, 201, 97)),
  sunset('Future Martian Orange', Color.fromARGB(255, 255, 120, 89)),
  amethyst('Code Purple', Color.fromARGB(255, 149, 117, 205));

  const AppColorScheme(this.label, this.seedColor);

  final String label;
  final Color seedColor;
}

class ColorSchemeProvider extends Notifier<AppColorScheme> {
  @override
  AppColorScheme build() {
    final storedScheme = prefs.getString(_colorSchemePrefKey);
    return AppColorScheme.values.firstWhere(
      (scheme) => scheme.name == storedScheme,
      orElse: () => AppColorScheme.cyan,
    );
  }

  void changeColorScheme(AppColorScheme value) {
    state = value;
    prefs.setString(_colorSchemePrefKey, value.name);
  }
}

final colorSchemeNotifierProvider =
    NotifierProvider<ColorSchemeProvider, AppColorScheme>(
      ColorSchemeProvider.new,
    );

class PapyrusFontProvider extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final papyrusFontProvider = NotifierProvider<PapyrusFontProvider, bool>(
  PapyrusFontProvider.new,
);
