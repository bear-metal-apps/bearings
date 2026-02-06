import 'package:beariscope_scouter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path/path.dart';

import '../custom_widgets/match_page.dart';

EventTypes selectedItem = EventTypes.all;
List<Widget> createTiles() {
  List<Widget> list = [];
  for (var event in events) {
    var searched = false;
    for (var string in event.commonPhrases) {
      if (string.contains(searchController.text)) {
        searched = true;
        break;
      }
    }
    if ((event.eventType == selectedItem || selectedItem == EventTypes.all) &&
        (searched ||
            event.name.contains(searchController.text) ||
            event.time.contains(searchController.text))) {
      list.add(
        ListTile(
          leading: Icon(Icons.check_circle),
          title: Text(event.name),
          subtitle: Text(event.time),
          onTap: () {},
          trailing: TextButton.icon(
            onPressed: () {
              if (event.eventType == EventTypes.match ||
                  event.eventType == EventTypes.all) {
                MyApp.router.go("/Match/Auto");
              } else if (event.eventType == EventTypes.strat) {
                MyApp.router.go("/Strat");
              }
            },
            label: Icon(Icons.open_in_full_outlined),
          ),
        ),
      );
    }
  }
  return list;
}

enum EventTypes { match, strat, all }

class Event {
  final String time;
  final String name;
  EventTypes eventType;
  String tbaMatchKey;
  final List<String> commonPhrases;

  Event({
    required this.time,
    required this.name,
    required this.eventType,
    this.tbaMatchKey = "",
    this.commonPhrases = const [],
  });
}

class MatchPage extends ConsumerStatefulWidget {
  const MatchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return MatchPageState();
  }
}

List<Event> events = [
  Event(
    time: '2:45',
    name: "Match 16",
    eventType: EventTypes.all,
    commonPhrases: ['Match', 'Strat'],
  ),
  Event(
    time: '3:00',
    name: "Match 17",
    eventType: EventTypes.all,
    commonPhrases: ['Match', 'Strat'],
  ),
  Event(
    time: '3:15',
    name: "Match 18",
    eventType: EventTypes.all,
    commonPhrases: ['Match', 'Strat'],
  ),
  Event(
    time: '3:30',
    name: "Match 19",
    eventType: EventTypes.all,
    commonPhrases: ['Match', 'Strat'],
  ),
  Event(
    time: '3:45',
    name: "Match 20",
    eventType: EventTypes.all,
    commonPhrases: ['Match', 'Strat'],
  ),
  Event(
    time: '4:00',
    name: "Match 21",
    eventType: EventTypes.match,
    commonPhrases: ['Match', 'Strat'],
  ),
  Event(
    time: '4:15',
    name: "Match 22",
    eventType: EventTypes.strat,
    commonPhrases: ['Match', 'Strat'],
  ),
  Event(
    time: '4:30',
    name: "Match 23",
    eventType: EventTypes.all,
    commonPhrases: ['Match', 'Strat'],
  ),
  Event(time: '4:45', name: "Lunch", eventType: EventTypes.all),
];
Set<String> _selectedAllianceSegment = {'red'};
Set<String> _selectedPositionSegment = {'pos1'};
Map<String, bool> filterValues = {
  "Chip 1": false,
  "Chip 2": false,
  "Chip 3": false,
  "Chip 4": false,
  "Chip 5": false,
  "Chip 6": false,
  "Chip 7": false,
  "Chip 8": false,
  "Chip 9": false,
  "Chip 10": false,
  "Chip 11": false,
  "Chip 12": false,
};
TextEditingController searchController = TextEditingController();

class MatchPageState extends ConsumerState<MatchPage> {
  List<ListTile>? searchList = events.map((event) {
    return ListTile(
      leading: Icon(Icons.check_circle),
      title: Text('${event.time} - ${event.name}'),
      onTap: () {},
      trailing: Icon(Icons.open_in_full_outlined),
    );
  }).toList();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SearchBar(
            controller: searchController,
            hintText: "Search matches...",
            onChanged: (value) {
              setState(() {
                searchList = createTiles().cast<ListTile>();
                createTiles();
              });
            },
          ),
          Padding(padding: EdgeInsets.all(8.0)),
          SegmentedButton<String>(
            style: ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(
                horizontal: 3.0,
                vertical: 1.0,
              ),
            ),
            segments: const <ButtonSegment<String>>[
              ButtonSegment<String>(value: 'red', label: Text('Red Alliance')),
              ButtonSegment<String>(
                value: 'blue',
                label: Text('Blue Alliance'),
              ),
            ],
            selected: _selectedAllianceSegment,
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _selectedAllianceSegment = newSelection;
              });
            },
            // Handle selection change
          ),
          Padding(padding: EdgeInsets.all(8.0)),
          SegmentedButton<String>(
            style: ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(
                horizontal: 3.0,
                vertical: 1.0,
              ),
            ),
            segments: const <ButtonSegment<String>>[
              ButtonSegment<String>(value: 'pos1', label: Text('Position 1')),
              ButtonSegment<String>(value: 'pos2', label: Text('Position 2')),
              ButtonSegment<String>(value: 'pos3', label: Text('Position 3')),
            ],
            selected: _selectedPositionSegment,
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _selectedPositionSegment = newSelection;
              });
            },
            // Handle selection change
          ),
          Padding(padding: EdgeInsets.all(8.0)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              // Or Wrap, if you need the chips to eventually wrap onto a new line if the screen is wide enough
              children: <Widget>[
                // Generate your list of Chip widgets here
                FilterChip(
                  label: Text("Chip 1"),
                  selected: filterValues["Chip 1"] ?? false,
                  onSelected: (bool value) {
                    setState(() {
                      filterValues["Chip 1"] = value;
                    });
                  },
                ),
                FilterChip(
                  label: Text("Chip 2"),
                  selected: filterValues["Chip 2"] ?? false,
                  onSelected: (bool value) {
                    setState(() {
                      filterValues["Chip 2"] = value;
                    });
                  },
                ),
                FilterChip(
                  label: Text("Chip 3"),
                  selected: filterValues["Chip 3"] ?? false,
                  onSelected: (bool value) {
                    setState(() {
                      filterValues["Chip 3"] = value;
                    });
                  },
                ),
                FilterChip(
                  label: Text("Chip 4"),
                  selected: filterValues["Chip 4"] ?? false,
                  onSelected: (bool value) {
                    setState(() {
                      filterValues["Chip 4"] = value;
                    });
                  },
                ),
              ],
            ),
          ),

          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: createTiles().length,
            itemBuilder: (context, index) {
              return createTiles()[index];
            },
          ),
        ],
      ),
    );
  }
}


//diddy kong racing