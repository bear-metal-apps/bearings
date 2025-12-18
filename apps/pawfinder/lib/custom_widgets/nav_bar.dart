import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/user.dart';

class NavBar extends StatefulWidget {
  final Widget page;
  final String title;
  final GoRouter router;
  final bool devMode;

  const NavBar({
    super.key,
    required this.page,
    required this.title,
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
      appBar: AppBar(title: Text(widget.title)),
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
                  widget.router.go('/Schedule');
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
              ListTile(
                leading: Icon(Icons.satellite_alt),
                title: Text("Pits"),
                onTap: () {
                  widget.router.go('/Pits');
                },
                //trailing: LoadingAnimationWidget.staggeredDotsWave(color: Colors.greenAccent, size: 20),
              ),
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
