 import 'dart:io';

import 'package:beariscope_scouter/custom_widgets/match_page.dart';
import 'package:beariscope_scouter/pages/match.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AutoPage extends ConsumerStatefulWidget {
  const AutoPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return AutoPageState();
  }
}

class AutoPageState extends ConsumerState<AutoPage> {
  @override
  Widget build(BuildContext context) {
    return MatchWidget(json: File("resources/ui_creator.json"), pageIndex: 0,);
  }
}
