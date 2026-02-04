enum HistoryType {
  face,
  document,
}

class HistoryItem {
  HistoryItem({
    required this.id,
    required this.type,
    required this.label,
    required this.createdAt,
    this.thumbnailPath,
  });

  final String id;
  final HistoryType type;
  final String label;
  final DateTime createdAt;
  final String? thumbnailPath;
}
