import '/app/modules/home/models/history_item.dart';

abstract class HistoryRepository {
  List<HistoryItem> loadHistory();
  Future<void> addHistoryItem(HistoryItem item);
  Stream<List<HistoryItem>> watchHistory();
}
