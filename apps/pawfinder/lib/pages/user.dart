import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return Center(child: Text("Welcome Back, $currentUser"),);
  }
}


class User{
  final String name;
  final IconData icon;
  const User({required this.name, this.icon = Icons.person});
}
String currentUser = "";