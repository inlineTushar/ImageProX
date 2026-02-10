import '/app/data/models/processing_result.dart';
import '/app/domain/entities/processed_result.dart';

class ProcessingResultMapper {
  ProcessedResult toDomain(ProcessingResult model) {
    return ProcessedResult(
      originalPath: model.originalPath,
      processedImagePath: model.processedImagePath,
      contentType: model.contentType,
      title: model.title,
      pdfPath: model.pdfPath,
      extractedText: model.extractedText,
    );
  }

  ProcessingResult toData(ProcessedResult entity) {
    return ProcessingResult(
      originalPath: entity.originalPath,
      processedImagePath: entity.processedImagePath,
      contentType: entity.contentType,
      title: entity.title,
      pdfPath: entity.pdfPath,
      extractedText: entity.extractedText,
    );
  }
}
