import 'package:hive/hive.dart';

import '/app/data/local/hive/history_adapters.dart';
import '/app/data/repository/history_repository.dart';
import '/app/data/models/history_item.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  Box<HistoryItem> get _box =>
      Hive.box<HistoryItem>(historyBoxName);

  @override
  List<HistoryItem> loadHistory() {
    final items = _box.values.toList(growable: false);
    if (items.isEmpty) return items;

    final invalidKeys = <dynamic>[];
    for (final entry in _box.toMap().entries) {
      final item = entry.value;
      if (item.originalPath.isEmpty || item.processedPath.isEmpty) {
        invalidKeys.add(entry.key);
      }
    }

    if (invalidKeys.isNotEmpty) {
      _box.deleteAll(invalidKeys);
      return _box.values.toList(growable: false);
    }

    return items;
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
