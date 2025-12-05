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
  final List<String> _driverSkill = [
    "2000",
    "1000",
    "2046",
  ];

  final List<String> _rigidity = [
    "2000",
    "1000",
    "2046",
  ];

  final List<String> _iForgot = [
    "2000",
    "1000",
    "2046",
  ];

  Function(int, int) _onReorder(List<String> list) {
    return (int oldIndex, int newIndex) => {
      setState(() {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final String item = list.removeAt(oldIndex);
        list.insert(newIndex, item);
      })
    };
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);


    return Scaffold(
      body: SingleChildScrollView(child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Column(children: [
            SizedBox(width: size.width,),
            SizedBox(width: 400, height: 160, child: ReorderableListView(onReorder: _onReorder(_driverSkill), children: [
              for (final String item in _driverSkill)
                ListTile(
                  key: ValueKey(item),
                  title: Text(item),
                  trailing: const Icon(Icons.drag_handle),
                )
            ])),

            SizedBox(width: 400, height: 160, child: ReorderableListView(onReorder: _onReorder(_rigidity), children: [
              for (final String item in _rigidity)
                ListTile(
                  key: ValueKey(item),
                  title: Text(item),
                  trailing: const Icon(Icons.drag_handle),
                )
            ])),

            SizedBox(width: 400, height: 160, child: ReorderableListView(onReorder: _onReorder(_iForgot), children: [
              for (final String item in _iForgot)
                ListTile(
                  key: ValueKey(item),
                  title: Text(item),
                  trailing: const Icon(Icons.drag_handle),
                )
            ])),
          ],),

        ]
      )));
  }
}