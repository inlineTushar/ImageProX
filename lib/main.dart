import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '/app/data/local/hive/history_adapters.dart';
import '/app/my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive
    ..registerAdapter(HistoryTypeAdapter())
    ..registerAdapter(HistoryItemAdapter());
  await Hive.openBox(historyBoxName);

  runApp(const MyApp());
}
