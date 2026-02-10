import 'dart:typed_data';

abstract class PdfService {
  Future<List<int>> buildFromImage(Uint8List imageBytes);
  Future<List<int>> buildFromText(String text);
}
