import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:imageprox/app/data/models/content_type.dart';
import 'package:imageprox/app/data/models/history_item.dart';
import 'package:imageprox/app/domain/entities/history_entry.dart';
import 'package:imageprox/app/domain/usecases/history_use_case.dart';
import 'package:imageprox/app/domain/repositories/history_repository.dart';

class _MockHistoryRepository extends Mock implements HistoryRepository {}

void main() {
  group('HistoryUseCase', () {
    late HistoryRepository repository;
    late HistoryUseCase useCase;

    setUp(() {
      repository = _MockHistoryRepository();
      useCase = HistoryUseCase(repository: repository);
    });

    test('loadHistory maps to domain entries', () {
      final items = [
        HistoryItem(
          id: '1',
          type: HistoryType.face,
          title: 'Face',
          createdAt: DateTime(2024, 1, 2),
          originalPath: '/o.jpg',
          processedPath: '/p.jpg',
        ),
      ];
      when(() => repository.loadHistory()).thenReturn(items);

      final result = useCase.loadHistory();

      expect(result, hasLength(1));
      expect(result.first, isA<HistoryEntry>());
      expect(result.first.type, ContentType.face);
      expect(result.first.title, 'Face');
      expect(result.first.originalPath, '/o.jpg');
    });

    test('watchHistory maps stream to domain entries', () async {
      final controller = StreamController<List<HistoryItem>>();
      when(() => repository.watchHistory())
          .thenAnswer((_) => controller.stream);

      final emitted = <List<HistoryEntry>>[];
      final sub = useCase.watchHistory().listen(emitted.add);

      controller.add([
        HistoryItem(
          id: '2',
          type: HistoryType.document,
          title: 'Doc',
          createdAt: DateTime(2024, 1, 3),
          originalPath: '/o2.jpg',
          processedPath: '/p2.jpg',
          pdfPath: '/d.pdf',
        ),
      ]);

      await Future<void>.delayed(Duration.zero);

      expect(emitted, hasLength(1));
      expect(emitted.first.first.type, ContentType.document);
      expect(emitted.first.first.pdfPath, '/d.pdf');

      await sub.cancel();
      await controller.close();
    });
  });
}
