import '/app/data/models/history_item.dart';
import '/app/domain/entities/history_entry.dart';
import '/app/data/models/content_type.dart';

class HistoryMapper {
  HistoryEntry toDomain(HistoryItem item) {
    return HistoryEntry(
      id: item.id,
      type: item.type == HistoryType.face
          ? ContentType.face
          : ContentType.document,
      title: item.title,
      createdAt: item.createdAt,
      originalPath: item.originalPath,
      processedPath: item.processedPath,
      thumbnailPath: item.thumbnailPath,
      pdfPath: item.pdfPath,
      extractedText: item.extractedText,
    );
  }

  HistoryItem toData(HistoryEntry entry) {
    return HistoryItem(
      id: entry.id,
      type: entry.type == ContentType.face
          ? HistoryType.face
          : HistoryType.document,
      title: entry.title,
      createdAt: entry.createdAt,
      originalPath: entry.originalPath,
      processedPath: entry.processedPath,
      thumbnailPath: entry.thumbnailPath,
      pdfPath: entry.pdfPath,
      extractedText: entry.extractedText,
    );
  }
}
