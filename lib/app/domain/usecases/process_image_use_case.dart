import 'dart:io';

import '/app/data/models/content_type.dart';
import '/app/data/models/history_item.dart';
import '/app/data/repository/history_repository.dart';
import '/app/data/services/processing_service.dart';
import '/app/data/services/processing_workflow_service.dart';
import '/app/data/models/processing_result.dart';

class ProcessImageUseCase {
  ProcessImageUseCase({
    required HistoryRepository repository,
    ProcessingService? processingService,
    ProcessingWorkflowService? workflowService,
  })  : _repository = repository,
        _processingService = processingService ?? ProcessingService(),
        _workflowService = workflowService ?? ProcessingWorkflowService();

  final HistoryRepository _repository;
  final ProcessingService _processingService;
  final ProcessingWorkflowService _workflowService;

  Future<ProcessingResult> run(
    File file, {
    ContentType? forcedType,
    double? scanWidthFactor,
    double? scanHeightFactor,
    required String faceTitle,
    required String documentTitle,
    void Function(ContentType type)? onDetected,
  }) async {
    final detection = await _workflowService.detectContent(
      file,
      forcedType: forcedType,
      scanWidthFactor: scanWidthFactor,
      scanHeightFactor: scanHeightFactor,
    );

    onDetected?.call(detection.contentType);

    final processed = await _processingService.process(
      file.path,
      contentType: detection.contentType,
      faceBoxes: detection.faceBoxes,
      textBounds: detection.textBounds,
      extractedText: detection.extractedText,
    );

    final title =
        detection.contentType == ContentType.face ? faceTitle : documentTitle;

    final resultWithTitle = ProcessingResult(
      originalPath: processed.originalPath,
      processedImagePath: processed.processedImagePath,
      contentType: processed.contentType,
      title: title,
      pdfPath: processed.pdfPath,
      extractedText: detection.extractedText,
    );

    await _repository.addHistoryItem(
      HistoryItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: detection.contentType == ContentType.face
            ? HistoryType.face
            : HistoryType.document,
        title: resultWithTitle.title,
        createdAt: DateTime.now(),
        originalPath: resultWithTitle.originalPath,
        processedPath: resultWithTitle.processedImagePath,
        thumbnailPath: resultWithTitle.processedImagePath,
        pdfPath: resultWithTitle.pdfPath,
        extractedText: resultWithTitle.extractedText,
      ),
    );

    return resultWithTitle;
  }

  Future<void> dispose() async {
    await _workflowService.dispose();
  }
}
