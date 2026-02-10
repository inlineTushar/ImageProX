import '/app/data/models/history_item.dart';
import '/app/data/repository/history_repository.dart';

class HistoryUseCase {
  HistoryUseCase({required HistoryRepository repository})
      : _repository = repository;

  final HistoryRepository _repository;

  List<HistoryItem> loadHistory() => _repository.loadHistory();

  Stream<List<HistoryItem>> watchHistory() => _repository.watchHistory();
}
