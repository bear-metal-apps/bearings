import 'dart:io';

import 'package:beariscope_scouter/custom_widgets/match_page.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TelePage extends ConsumerStatefulWidget {
  const TelePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return TelePageState();
  }
}

class TelePageState extends ConsumerState<TelePage> {
  @override
  Widget build(BuildContext context) {
    return MatchWidget(json: File("resources/ui_creator.json"), pageIndex: 1,);
  }
}
