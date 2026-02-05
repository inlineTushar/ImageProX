import '/app/modules/processing/controllers/processing_controller.dart';

class ProcessingResult {
  ProcessingResult({
    required this.originalPath,
    required this.processedImagePath,
    required this.contentType,
    required this.title,
    this.pdfPath,
  });

  final String originalPath;
  final String processedImagePath;
  final ContentType contentType;
  final String title;
  final String? pdfPath;
}
