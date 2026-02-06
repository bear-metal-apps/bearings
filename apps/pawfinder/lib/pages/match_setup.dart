import 'package:beariscope_scouter/main.dart';
import 'package:beariscope_scouter/pages/schedule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path/path.dart';

import 'match_page.dart';

EventTypes selectedItem = EventTypes.all;

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

class MatchSetUpPage extends ConsumerStatefulWidget {
  const MatchSetUpPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return MatchSetUpPageState();
  }
}

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

class MatchSetUpPageState extends ConsumerState<MatchSetUpPage> {
  EventTypes scoutType = EventTypes.match;
  List<Widget> createTiles(BuildContext context) {
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
            trailing: IconButton(
              icon: Icon(Icons.open_in_full_outlined),
              onPressed: () {
                if (scoutType == EventTypes.match) {
                  context.push("/auto", extra: event.matchIdentity);
                } else if (scoutType == EventTypes.strat) {
                  context.go("/strat");
                }
              },
            ),
          ),
        );
      }
    }
    return list;
  }

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
                searchList = createTiles(context).cast<ListTile>();
                createTiles(context);
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
              ButtonSegment<String>(value: 'strat', label: Text('Strat')),
            ],
            selected: _selectedPositionSegment,
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _selectedPositionSegment = newSelection;
                if(newSelection.contains('strat')){
                  scoutType = EventTypes.strat;
                }else{
                  scoutType = EventTypes.match;
                }
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
            itemCount: createTiles(context).length,
            itemBuilder: (context, index) {
              return createTiles(context)[index];
            },
          ),
        ],
      ),
    );
  }
}