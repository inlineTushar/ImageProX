import '/app/data/models/content_type.dart';

class ProcessingResult {
  ProcessingResult({
    required this.originalPath,
    required this.processedImagePath,
    required this.contentType,
    required this.title,
    this.pdfPath,
    this.extractedText,
  });

  final String originalPath;
  final String processedImagePath;
  final ContentType contentType;
  final String title;
  final String? pdfPath;
  final String? extractedText;
}
