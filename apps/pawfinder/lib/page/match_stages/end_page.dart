import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EndPage extends ConsumerStatefulWidget {
  const EndPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return EndPageState();
  }
}

class EndPageState extends ConsumerState<EndPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [

        ]
      ))
    );
  }
}
