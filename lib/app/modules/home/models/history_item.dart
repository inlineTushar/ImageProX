enum HistoryType {
  face,
  document,
}

class HistoryItem {
  HistoryItem({
    required this.id,
    required this.type,
    required this.title,
    required this.createdAt,
    required this.originalPath,
    required this.processedPath,
    this.thumbnailPath,
    this.pdfPath,
  });

  final String id;
  final HistoryType type;
  final String title;
  final DateTime createdAt;
  final String originalPath;
  final String processedPath;
  final String? thumbnailPath;
  final String? pdfPath;
}
