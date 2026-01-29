import 'package:hive_ce_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

const boxKey = "localData";
const jsonBoxKey = "localDataJson"; /* Contains all saved JSONs */

Future<void> loadHive() async {
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  await Hive.openBox(boxKey); // so the code doesn't have to use openBox
  await Hive.openBox(jsonBoxKey);
}

/*
///
/// Loads hive_ce data into Riverpod states.
///
void loadPersistentData() {
  Hive.openBox(boxKey)
    .then((data) {
      final container = ProviderContainer();
      List<String>? driverSkillData = data.get('driverSkill');

      if (driverSkillData != null) {
        print(driverSkillData);
        final driverSkill = container.read(driverSkillNotifierProvider.notifier);
        driverSkill.set(["6", "7"]);
      }

      
      container.dispose();
    })
    .catchError((err) {

    });
}

///
/// Reads Riverpod states and saves their datas to hive_ce.
///
void savePersistentData() {
  print("hi");
  final data = Hive.box(boxKey);
  final container = ProviderContainer();

  data.clear();

  final driverSkill = container.read(driverSkillNotifierProvider.notifier);

  data.put("driverSkill", driverSkill.get());

  print(data.get("driverSkill"));
  print(driverSkill.get());
  
  container.dispose();
}

*/
