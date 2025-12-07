import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StratPage extends ConsumerStatefulWidget {
  const StratPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return StratPageState();
  }
}

class StratPageState extends ConsumerState<StratPage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Strat'));
  }
}