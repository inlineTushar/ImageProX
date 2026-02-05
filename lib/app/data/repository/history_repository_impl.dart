import 'package:hive/hive.dart';

import '/app/data/local/hive/history_adapters.dart';
import '/app/data/repository/history_repository.dart';
import '/app/modules/home/models/history_item.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  Box<HistoryItem> get _box =>
      Hive.box<HistoryItem>(historyBoxName);

  @override
  List<HistoryItem> loadHistory() {
    return _box.values.toList(growable: false);
  }

  @override
  Future<void> addHistoryItem(HistoryItem item) async {
    await _box.add(item);
  }

  @override
  Stream<List<HistoryItem>> watchHistory() {
    return _box.watch().map((_) => _box.values.toList(growable: false));
  }
}
