import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageNormalizer {
  Future<File?> normalize(File file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    final oriented = img.bakeOrientation(decoded);
    final tempDir = await getTemporaryDirectory();
    final normalized = File(
      '${tempDir.path}/normalized_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    await normalized.writeAsBytes(img.encodeJpg(oriented, quality: 95));
    return normalized;
  }
}
