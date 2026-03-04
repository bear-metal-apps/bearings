import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BrightnessProvider extends Notifier<Brightness> {
  @override
  Brightness build() => Brightness.light;

  void changeBrightness(bool value) =>
      !value ? state = Brightness.dark : state = Brightness.light;
}

final brightnessNotifierProvider =
    NotifierProvider<BrightnessProvider, Brightness>(BrightnessProvider.new);
