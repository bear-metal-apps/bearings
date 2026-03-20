import 'package:beariscope/models/scouting_document.dart';

class ProcessedScoutingDoc {
  final ScoutingDocument raw;
  final double autoFuelScalar;
  final double teleFuelScalar;

  const ProcessedScoutingDoc({
    required this.raw,
    this.autoFuelScalar = 1.0,
    this.teleFuelScalar = 1.0,
  });

  bool get isScaled =>
      (autoFuelScalar - 1.0).abs() > 0.01 ||
      (teleFuelScalar - 1.0).abs() > 0.01;
}
