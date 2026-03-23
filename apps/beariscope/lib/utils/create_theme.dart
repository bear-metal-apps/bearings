import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData createTheme(Brightness brightness, Color accentColor) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: accentColor,
    brightness: brightness,
  );

  final baseTheme = ThemeData(
    brightness: brightness,
    useMaterial3: true,
    colorScheme: colorScheme,
    iconTheme: IconThemeData(
      fill: 0.0,
      weight: 600,
      color: colorScheme.onSurface,
    ),
    textTheme: GoogleFonts.nunitoSansTextTheme(
      ThemeData(brightness: brightness, colorScheme: colorScheme).textTheme,
    ),
  );

  return baseTheme.copyWith(
    appBarTheme: baseTheme.appBarTheme.copyWith(
      centerTitle: false,
      titleTextStyle: baseTheme.textTheme.titleLarge!.copyWith(
        fontFamily: 'Xolonium',
        fontSize: 20,
      ),
    ),
    dialogTheme: baseTheme.dialogTheme.copyWith(
      titleTextStyle: baseTheme.textTheme.headlineSmall!.copyWith(
        fontFamily: 'Xolonium',
        fontSize: 20,
      ),
    ),
  );
}
