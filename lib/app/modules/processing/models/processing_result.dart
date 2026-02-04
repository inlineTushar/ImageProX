import '/app/modules/processing/controllers/processing_controller.dart';

class ProcessingResult {
  ProcessingResult({
    required this.imagePath,
    required this.contentType,
  });

  final String imagePath;
  final ContentType contentType;
}
