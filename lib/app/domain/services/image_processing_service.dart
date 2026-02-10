import 'dart:typed_data';

import '/app/data/models/content_type.dart';

abstract class ImageProcessingService {
  Future<Uint8List> process(
    String imagePath, {
    required ContentType contentType,
    List<List<double>>? faceBoxes,
    List<double>? textBounds,
  });
}
