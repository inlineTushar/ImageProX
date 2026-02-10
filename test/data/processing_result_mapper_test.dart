import 'package:flutter_test/flutter_test.dart';

import 'package:imageprox/app/data/mappers/processing_result_mapper.dart';
import 'package:imageprox/app/data/models/content_type.dart';
import 'package:imageprox/app/data/models/processing_result.dart';
import 'package:imageprox/app/domain/entities/processed_result.dart';

void main() {
  group('ProcessingResultMapper', () {
    final mapper = ProcessingResultMapper();

    test('toDomain maps ProcessingResult to ProcessedResult', () {
      final model = ProcessingResult(
        originalPath: '/o.jpg',
        processedImagePath: '/p.jpg',
        contentType: ContentType.face,
        title: 'Face',
        pdfPath: null,
        extractedText: 'text',
      );

      final entity = mapper.toDomain(model);

      expect(entity, isA<ProcessedResult>());
      expect(entity.contentType, ContentType.face);
      expect(entity.extractedText, 'text');
    });

    test('toData maps ProcessedResult to ProcessingResult', () {
      final entity = ProcessedResult(
        originalPath: '/o2.jpg',
        processedImagePath: '/p2.jpg',
        contentType: ContentType.document,
        title: 'Doc',
        pdfPath: '/d.pdf',
        extractedText: 'hello',
      );

      final model = mapper.toData(entity);

      expect(model.contentType, ContentType.document);
      expect(model.pdfPath, '/d.pdf');
      expect(model.extractedText, 'hello');
    });
  });
}
