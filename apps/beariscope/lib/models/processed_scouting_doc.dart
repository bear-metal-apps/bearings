import 'package:beariscope/models/scouting_document.dart';

class ProcessedScoutingDoc {
  final ScoutingDocument raw;
  final double autoFuelScalar;
  final double teleFuelScalar;
  final int autoHumanPlayerScore;
  final int teleHumanPlayerScore;

  const ProcessedScoutingDoc({
    required this.raw,
    this.autoFuelScalar = 1.0,
    this.teleFuelScalar = 1.0,
    this.autoHumanPlayerScore = 0,
    this.teleHumanPlayerScore = 0,
  });

  int get totalHumanPlayerScore => autoHumanPlayerScore + teleHumanPlayerScore;

  bool get isScaled =>
      (autoFuelScalar - 1.0).abs() > 0.01 ||
      (teleFuelScalar - 1.0).abs() > 0.01;
}
