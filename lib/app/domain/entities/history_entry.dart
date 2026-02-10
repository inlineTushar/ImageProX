import '/app/data/models/content_type.dart';

class HistoryEntry {
  HistoryEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.createdAt,
    required this.originalPath,
    required this.processedPath,
    this.thumbnailPath,
    this.pdfPath,
    this.extractedText,
  });

  final String id;
  final ContentType type;
  final String title;
  final DateTime createdAt;
  final String originalPath;
  final String processedPath;
  final String? thumbnailPath;
  final String? pdfPath;
  final String? extractedText;
}
