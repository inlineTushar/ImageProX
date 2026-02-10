import '/app/data/mappers/history_mapper.dart';
import '/app/domain/repositories/history_repository.dart';
import '/app/domain/entities/history_entry.dart';

class HistoryUseCase {
  HistoryUseCase({
    required HistoryRepository repository,
    HistoryMapper? mapper,
  })  : _repository = repository,
        _mapper = mapper ?? HistoryMapper();

  final HistoryRepository _repository;
  final HistoryMapper _mapper;

  List<HistoryEntry> loadHistory() =>
      _repository.loadHistory().map(_mapper.toDomain).toList();

  Stream<List<HistoryEntry>> watchHistory() =>
      _repository.watchHistory().map((items) {
        return items.map(_mapper.toDomain).toList();
      });
}
