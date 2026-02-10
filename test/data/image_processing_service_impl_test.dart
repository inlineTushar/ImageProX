import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:imageprox/app/data/models/content_type.dart';
import 'package:imageprox/app/data/services/image_processing_service_impl.dart';
import 'package:imageprox/app/domain/services/image_processing_service.dart';

void main() {
  group('ImageProcessingServiceImpl', () {
    late ImageProcessingService service;
    late Directory tempDir;

    setUp(() async {
      service = ImageProcessingServiceImpl();
      tempDir = await Directory.systemTemp.createTemp('imageproc_test');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('processes face content and returns bytes', () async {
      final image = img.Image(width: 10, height: 10);
      img.fill(image, color: img.ColorRgb8(255, 0, 0));
      final file = File('${tempDir.path}/face.jpg');
      await file.writeAsBytes(img.encodeJpg(image));

      final bytes = await service.process(
        file.path,
        contentType: ContentType.face,
        faceBoxes: [
          [0, 0, 5, 5],
        ],
      );

      expect(bytes, isA<Uint8List>());
      expect(bytes.length, greaterThan(0));
    });

    test('processes document content and returns bytes', () async {
      final image = img.Image(width: 10, height: 10);
      img.fill(image, color: img.ColorRgb8(255, 255, 255));
      final file = File('${tempDir.path}/doc.jpg');
      await file.writeAsBytes(img.encodeJpg(image));

      final bytes = await service.process(
        file.path,
        contentType: ContentType.document,
        textBounds: [0, 0, 10, 10],
      );

      expect(bytes, isA<Uint8List>());
      expect(bytes.length, greaterThan(0));
    });
  });
}
