import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImagePreprocessor {
  Future<File?> enhanceForOcr(File file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    final enhanced = img.grayscale(decoded);
    final adjusted = img.adjustColor(
      enhanced,
      contrast: 1.2,
      brightness: 1.1,
    );

    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
      '${tempDir.path}/ocr_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    await tempFile.writeAsBytes(img.encodeJpg(adjusted, quality: 90));
    return tempFile;
  }
}
