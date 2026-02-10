import 'package:flutter_test/flutter_test.dart';

import 'package:imageprox/app/data/mappers/history_mapper.dart';
import 'package:imageprox/app/data/models/content_type.dart';
import 'package:imageprox/app/data/models/history_item.dart';
import 'package:imageprox/app/domain/entities/history_entry.dart';

void main() {
  group('HistoryMapper', () {
    final mapper = HistoryMapper();

    test('toDomain maps HistoryItem to HistoryEntry', () {
      final item = HistoryItem(
        id: '1',
        type: HistoryType.face,
        title: 'Face',
        createdAt: DateTime(2024, 1, 2),
        originalPath: '/o.jpg',
        processedPath: '/p.jpg',
        thumbnailPath: '/t.jpg',
        pdfPath: null,
        extractedText: 'hi',
      );

      final entry = mapper.toDomain(item);

      expect(entry, isA<HistoryEntry>());
      expect(entry.type, ContentType.face);
      expect(entry.title, 'Face');
      expect(entry.extractedText, 'hi');
    });

    test('toData maps HistoryEntry to HistoryItem', () {
      final entry = HistoryEntry(
        id: '2',
        type: ContentType.document,
        title: 'Doc',
        createdAt: DateTime(2024, 1, 3),
        originalPath: '/o2.jpg',
        processedPath: '/p2.jpg',
        thumbnailPath: '/t2.jpg',
        pdfPath: '/d.pdf',
        extractedText: 'text',
      );

      final item = mapper.toData(entry);

      expect(item.type, HistoryType.document);
      expect(item.pdfPath, '/d.pdf');
      expect(item.extractedText, 'text');
    });
  });
}
