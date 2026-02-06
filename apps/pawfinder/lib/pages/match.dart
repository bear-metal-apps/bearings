import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatchSetUpPage extends ConsumerStatefulWidget {
  const MatchSetUpPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return MatchSetUpPageState();
  }
}

class MatchSetUpPageState extends ConsumerState<MatchSetUpPage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Match Page"));
  }
}

