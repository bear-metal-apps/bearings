import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  final List<String> highlightTeams;

  const MatchCard({
    super.key,
    required this.match,
    required this.highlightTeams,
  });

  @override
  Widget build(BuildContext context) {
    final String mKey = match['key']?.toString() ?? '';
    final alliances = match['alliances'] ?? {};
    final red = alliances['red'] ?? {};
    final blue = alliances['blue'] ?? {};
    final redScore = red['score'] ?? 0;
    final blueScore = blue['score'] ?? 0;

    final matchNum = match['match_number'] ?? '';
    final setNum = match['set_number'] ?? '';
    final compLevel = match['comp_level'] ?? 'qm';

    final type = switch (compLevel) {
      'qm' => 'Qualification Match $matchNum',
      'sf' => 'Semifinal Match $setNum',
      'f' => 'Final Match $matchNum',
      _ => '${compLevel.toUpperCase()}',
    };

    List<String> parseTeams(dynamic keys) => (keys as List? ?? [])
        .map((e) => e.toString().replaceFirst('frc', ''))
        .toList();

    final redTeams = parseTeams(red['team_keys']);
    final blueTeams = parseTeams(blue['team_keys']);

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: MediaQuery.of(context).size.width > 700 ? 600 : double.infinity,
        child: Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                if (mKey.isNotEmpty) {
                  context.push('/up_next/$mKey');
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$type',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    Divider(height: 24, thickness: 1, color: Colors.grey),

                    _buildAllianceRow(
                      'Blue Alliance',
                      blueTeams,
                      Colors.blue.shade700,
                    ),

                    Divider(height: 24, thickness: 1, color: Colors.grey),

                    _buildAllianceRow(
                      'Red Alliance',
                      redTeams,
                      Colors.red.shade700,
                    ),

                    Divider(height: 24, thickness: 1, color: Colors.grey),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Score',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            children: [
                              TextSpan(
                                text: '$blueScore',
                                style: TextStyle(color: Colors.blue.shade700),
                              ),
                              const TextSpan(
                                  text: ' – ',
                                  style: TextStyle(color: Colors.white)
                              ),
                              TextSpan(
                                text: '$redScore',
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
        ),
      ),
    );
  }

  Widget _buildAllianceRow(
      String label,
      List<String> teams,
      Color allianceColor,
      ) {
    final normalStyle = const TextStyle(
      color: Colors.white,
      fontSize: 15,
    );
    final highlightStyle = TextStyle(
      color: allianceColor,
      fontSize: 15,
      fontWeight: FontWeight.bold,
      decorationColor: allianceColor,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: normalStyle,
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: allianceColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...teams.asMap().entries.map((entry) {
              final team = entry.value;
              final isLast = entry.key == teams.length - 1;
              final isHighlighted = highlightTeams.contains(team) ||
                  highlightTeams.contains('frc$team');

              return TextSpan(
                text: '$team${isLast ? '' : ', '}',
                style: isHighlighted ? highlightStyle : normalStyle,
              );
            }),
          ],
        ),
      ),
    );
  }
}