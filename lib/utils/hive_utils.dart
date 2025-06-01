import 'package:hive/hive.dart';

Future<Box<T>> getSafeBox<T>(String name) async {
  if (Hive.isBoxOpen(name)) {
    return Hive.box<T>(name);
  } else {
    return await Hive.openBox<T>(name);
  }
}
