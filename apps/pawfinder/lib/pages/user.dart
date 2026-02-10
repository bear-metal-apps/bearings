import 'package:beariscope_scouter/custom_widgets/big_number.dart';
import 'package:flutter/material.dart';
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
    return Center(child: Column(
      children: [
        Text("Welcome Back, $currentUser"),
        BigNumberWidget(buttons: [
          5, 1, 2, -3
        ], xLength: 200, yLength: 200, text: "poo",)
      ]));
  }
}

class User {
  final String name;
  final IconData icon;
  const User({required this.name, this.icon = Icons.person});
}

String currentUser = "";
