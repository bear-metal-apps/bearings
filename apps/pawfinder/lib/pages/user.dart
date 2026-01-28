import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

List<Widget> cardList = [
  Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black12),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: ListTile(
      trailing: Icon(Icons.chevron_right),
      leading: Icon(Icons.casino),
      title: Text('Logout'),
      subtitle: Text('\$500'),
      onTap: () {},
    ),
  ),
  Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black12),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: ListTile(
      trailing: Icon(Icons.chevron_right),
      leading: Icon(Icons.casino),
      title: Text('Logout'),
      subtitle: Text('Current User: $currentUser'),
      onTap: () {},
    ),
  ),
  Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black12),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: ListTile(
      trailing: Icon(Icons.chevron_right),
      leading: Icon(Icons.casino),
      title: Text('Logout'),
      subtitle: Text('Current User: $currentUser'),
      onTap: () {},
    ),
  ),
];

class UserPage extends ConsumerStatefulWidget {
  const UserPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return UserPageState();
  }
}

class UserPageState extends ConsumerState<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Expanded(
              child: SizedBox(
                height: 200,
                child: CarouselView(
                  itemExtent: 200,
                  children: [
                    Icon(Icons.image, size: 50),
                    Icon(Icons.image, size: 50),
                    Icon(Icons.image, size: 50),
                    Icon(Icons.image, size: 50),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              bottom: 5.0,
              top: 5.0,
            ),
            child: cardList[0],
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              bottom: 5.0,
              top: 5.0,
            ),
            child: cardList[1],
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              bottom: 5.0,
              top: 5.0,
            ),
            child: cardList[2],
          ),
          Text('bottom of page'),
        ],
      ),
    );
  }
}

class User {
  final String name;
  final IconData icon;
  const User({required this.name, this.icon = Icons.person});
}

String currentUser = "";
