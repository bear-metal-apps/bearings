import 'package:beariscope/models/match_field_ids.dart';
import 'package:beariscope/models/processed_scouting_doc.dart';
import 'package:beariscope/models/scouting_document.dart';
import 'package:beariscope/models/tba_match_score.dart';
import 'package:beariscope/models/team_scouting_bundle.dart';
import 'package:beariscope/providers/scouting_data_provider.dart';
import 'package:beariscope/providers/tba_match_scores_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final processedScoutingProvider = FutureProvider<List<ProcessedScoutingDoc>>((
  ref,
) async {
  final allDocs = await ref.watch(scoutingDataProvider.future);
  final tbaMatchScores = await ref.watch(tbaMatchScoresProvider.future);

  final processedById = <String, ProcessedScoutingDoc>{
    for (final doc in allDocs) doc.id: ProcessedScoutingDoc(raw: doc),
  };

  final docsByMatchNumber = <int, List<ScoutingDocument>>{};
  for (final doc in allDocs) {
    if (doc.meta?['type']?.toString() != 'match') continue;
    final matchNumber = TeamScoutingBundle.matchNumber(doc);
    if (matchNumber == null || matchNumber <= 0) continue;
    docsByMatchNumber.putIfAbsent(matchNumber, () => []).add(doc);
  }

  for (final tbaScore in tbaMatchScores.values) {
    final matchDocs = docsByMatchNumber[tbaScore.matchNumber];
    if (matchDocs == null || matchDocs.isEmpty) continue;

    _applyScalars(
      processedById: processedById,
      matchDocs: matchDocs,
      teamKeys: tbaScore.redTeams,
      score: tbaScore.red.scoreBreakdown,
    );
    _applyScalars(
      processedById: processedById,
      matchDocs: matchDocs,
      teamKeys: tbaScore.blueTeams,
      score: tbaScore.blue.scoreBreakdown,
    );
  }

  return allDocs
      .map((doc) => processedById[doc.id] ?? ProcessedScoutingDoc(raw: doc))
      .toList();
});

void _applyScalars({
  required Map<String, ProcessedScoutingDoc> processedById,
  required List<ScoutingDocument> matchDocs,
  required List<String> teamKeys,
  required TbaAllianceScore score,
}) {
  final allianceDocs = matchDocs.where((doc) {
    final teamNumber = TeamScoutingBundle.teamNumber(doc);
    if (teamNumber == null) return false;
    return teamKeys.contains('frc$teamNumber');
  }).toList();

  if (allianceDocs.isEmpty) return;

  final scoutedAuto = _sumFuel(allianceDocs, kSectionAuto, kAutoFuelScored);
  final scoutedTele = _sumFuel(allianceDocs, kSectionTele, kTeleFuelScored);

  final autoScalar = score.autoFuelScored > 0 && scoutedAuto > 0
      ? score.autoFuelScored / scoutedAuto
      : 1.0;
  final teleScalar = score.teleFuelScored > 0 && scoutedTele > 0
      ? score.teleFuelScored / scoutedTele
      : 1.0;

  for (final doc in allianceDocs) {
    processedById[doc.id] = ProcessedScoutingDoc(
      raw: doc,
      autoFuelScalar: autoScalar,
      teleFuelScalar: teleScalar,
    );
  }
}

double _sumFuel(List<ScoutingDocument> docs, String sectionId, String fieldId) {
  double sum = 0;
  for (final doc in docs) {
    final value = TeamScoutingBundle.getMatchField(doc, sectionId, fieldId);
    if (value is num) {
      sum += value.toDouble();
    }
  }
  return sum;
}
