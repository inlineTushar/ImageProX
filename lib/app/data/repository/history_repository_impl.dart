import 'package:hive/hive.dart';

import '/app/data/local/hive/history_adapters.dart';
import '/app/data/repository/history_repository.dart';
import '/app/modules/home/models/history_item.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  Box<HistoryItem> get _box =>
      Hive.box<HistoryItem>(historyBoxName);

  @override
  List<HistoryItem> loadHistory() {
    if (_box.isEmpty) {
      final seed = [
        HistoryItem(
          id: '1',
          type: HistoryType.face,
          label: 'Face Processed',
          createdAt: DateTime(2026, 1, 14),
        ),
        HistoryItem(
          id: '2',
          type: HistoryType.document,
          label: 'Document Scan',
          createdAt: DateTime(2026, 1, 14),
        ),
      ];
      _box.addAll(seed);
    }

    return _box.values.toList(growable: false);
  }
}
