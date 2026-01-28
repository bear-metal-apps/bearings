import 'package:beariscope_scouter/pages/user.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/schedule.dart';

class NavBar extends StatefulWidget {
  final Widget page;
  final Widget appBar;
  final GoRouter router;
  final bool devMode;

  const NavBar({
    super.key,
    required this.page,
    required this.appBar,
    required this.router,
    this.devMode = false,
  });

  @override
  State<StatefulWidget> createState() {
    return NavBarState();
  }
}

class NavBarState extends State<NavBar> {
  final List<User> users = [User(name: 'BenD'), User(name: 'MatthewS')];

  @override
  Widget build(BuildContext context) {
    List<Widget> userButtons = [];
    for (var element in users) {
      userButtons.add(
        ListTile(
          leading: Icon(element.icon),
          title: Text(element.name),
          onTap: () {
            currentUser = element.name;
            widget.router.go('/User');
          },
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: widget.appBar,
        toolbarHeight: MediaQuery.of(context).size.height * 3 / 32,
      ),
      body: widget.page,
      drawer: Drawer(
        width: 250.0,
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(6.0),
          child: ListView(
            children: [
              Align(
                alignment: Alignment.center,
                child: Text("Paw Finder", textScaler: TextScaler.linear(1.2)),
              ),
              ListTile(
                leading: Icon(Icons.calendar_month),
                title: Text("Schedule"),
                onTap: () {
                  widget.router.go('/');
                },
              ),
              Divider(),
              Text("Scouting"),
              ListTile(
                leading: Icon(Icons.timer),
                title: Text("Match"),
                onTap: () {
                  widget.router.go('/Match');
                },
                //trailing: LoadingAnimationWidget.staggeredDotsWave(color: Colors.greenAccent, size: 20),
              ),
              ListTile(
                leading: Icon(Icons.linear_scale),
                title: Text("Strat"),
                onTap: () {
                  widget.router.go('/Strat');
                },
                //trailing: LoadingAnimationWidget.staggeredDotsWave(color: Colors.greenAccent, size: 20),
              ),
              // ListTile(
              //   leading: Icon(Icons.satellite_alt),
              //   title: Text("Pits"),
              //   onTap: () {
              //     widget.router.go('/Pits');
              //   },
              //   //trailing: LoadingAnimationWidget.staggeredDotsWave(color: Colors.greenAccent, size: 20),
              // ),
              Divider(),
              Text("Users"),
              Column(children: userButtons),
              Align(
                alignment: Alignment.bottomCenter,
                child: OutlinedButton(
                  onPressed: () {
                    print('Syncing');
                  },
                  child: Text('Sync'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MatchNavBar extends StatefulWidget {
  final Widget page;
  final GoRouter router;
  final bool devMode;
  MatchInformation matchInformation;

  MatchNavBar({
    super.key,
    required this.page,
    required this.router,
    this.devMode = false,
    MatchInformation? matchInformation,
  }) : matchInformation = matchInformation ?? MatchInformation();

  @override
  State<StatefulWidget> createState() {
    return MatchNavBarState();
  }
}

class MatchNavBarState extends State<MatchNavBar> {
  final List<User> users = [User(name: 'BenD'), User(name: 'MatthewS')];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    if (location.startsWith('/Strat')) return 1;
    if (location.startsWith('/User')) return 2;

    return 0; // Schedule
  }

  String returnPosition() {
    switch (widget.matchInformation.position) {
      case Positions.red1:
        return 'Red 1';
      case Positions.red2:
        return 'Red 2';
      case Positions.red3:
        return 'Red 3';
      case Positions.blue1:
        return 'Blue 1';
      case Positions.blue2:
        return 'Blue 2';
      case Positions.blue3:
        return 'Blue 3';
      case Positions.none:
        return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> userButtons = [];
    for (var element in users) {
      userButtons.add(
        ListTile(
          leading: Icon(element.icon),
          title: Text(element.name),
          onTap: () {
            currentUser = element.name;
            widget.router.go('/User');
          },
        ),
      );
      // ignore: unused_element
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("Match ${widget.matchInformation.matchID}"),
            VerticalDivider(),
            Text(returnPosition()),
            VerticalDivider(),
            Text("Robot ${widget.matchInformation.robot}"),
          ],
        ),
        toolbarHeight: MediaQuery.of(context).size.height * 3 / 32,
      ),
      drawer: Drawer(
        width: 250.0,
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(6.0),
          child: ListView(
            children: [
              Align(
                alignment: Alignment.center,
                child: Text("Paw Finder", textScaler: TextScaler.linear(1.2)),
              ),
              ListTile(
                leading: Icon(Icons.calendar_month),
                title: Text("Schedule"),
                onTap: () {
                  widget.router.go('/');
                },
              ),
              Divider(),
              Text("Scouting"),
              ListTile(
                leading: Icon(Icons.timer),
                title: Text("Match"),
                onTap: () {
                  widget.router.go('/Match');
                },
                //trailing: LoadingAnimationWidget.staggeredDotsWave(color: Colors.greenAccent, size: 20),
              ),
              ListTile(
                leading: Icon(Icons.linear_scale),
                title: Text("Strat"),
                onTap: () {
                  widget.router.go('/Strat');
                },
                //trailing: LoadingAnimationWidget.staggeredDotsWave(color: Colors.greenAccent, size: 20),
              ),
              // ListTile(
              //   leading: Icon(Icons.satellite_alt),
              //   title: Text("Pits"),
              //   onTap: () {
              //     widget.router.go('/Pits');
              //   },
              //   //trailing: LoadingAnimationWidget.staggeredDotsWave(color: Colors.greenAccent, size: 20),
              // ),
              Divider(),
              Text("Users"),
              Column(children: userButtons),
              Align(
                alignment: Alignment.bottomCenter,
                child: OutlinedButton(
                  onPressed: () {
                    print('Syncing');
                  },
                  child: Text('Sync'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: widget.page,
      bottomNavigationBar: SizedBox(
        height: MediaQuery.of(context).size.height * 3 / 32,
        child: BottomNavigationBar(
          currentIndex: _currentIndex(context),
          onTap: (index) {
            switch (index) {
              case 0:
                widget.router.go('/Match/Auto');
                break;
              case 1:
                widget.router.go('/Match/Tele');
                break;
              case 2:
                widget.router.go('/Match/End');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.bolt), label: "Auto"),
            BottomNavigationBarItem(
              icon: Icon(Icons.stacked_bar_chart_sharp),
              label: "Tele",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_array),
              label: "Endgame",
            ),
          ],
        ),
      ),
    );
  }
}
