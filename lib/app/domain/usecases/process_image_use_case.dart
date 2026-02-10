import 'dart:io';
import 'dart:typed_data';

import '/app/data/models/content_type.dart';
import '/app/data/mappers/history_mapper.dart';
import '/app/data/repository/history_repository.dart';
import '/app/data/services/processing_workflow_service.dart';
import '/app/data/mappers/processing_result_mapper.dart';
import '/app/data/models/processing_result.dart';
import '/app/data/services/storage_service.dart';
import '/app/domain/services/image_processing_service.dart';
import '/app/domain/services/pdf_service.dart';
import '/app/domain/services/storage_service.dart';
import '/app/domain/entities/processed_result.dart';
import '/app/domain/entities/history_entry.dart';

class ProcessImageUseCase {
  ProcessImageUseCase({
    required HistoryRepository repository,
    required ImageProcessingService imageProcessingService,
    required PdfService pdfService,
    required StorageService storageService,
    required ProcessingWorkflowService workflowService,
    HistoryMapper? historyMapper,
    ProcessingResultMapper? resultMapper,
  })  : _repository = repository,
        _imageProcessingService = imageProcessingService,
        _pdfService = pdfService,
        _storageService = storageService,
        _workflowService = workflowService,
        _historyMapper = historyMapper ?? HistoryMapper(),
        _resultMapper = resultMapper ?? ProcessingResultMapper();

  final HistoryRepository _repository;
  final ImageProcessingService _imageProcessingService;
  final PdfService _pdfService;
  final StorageService _storageService;
  final ProcessingWorkflowService _workflowService;
  final HistoryMapper _historyMapper;
  final ProcessingResultMapper _resultMapper;

  String _two(int value) => value.toString().padLeft(2, '0');

  Future<ProcessedResult> run(
    String imagePath, {
    ContentType? forcedType,
    double? scanWidthFactor,
    double? scanHeightFactor,
    required String faceTitle,
    required String documentTitle,
    void Function(ContentType type)? onDetected,
  }) async {
    final file = File(imagePath);
    final detection = await _workflowService.detectContent(
      file,
      forcedType: forcedType,
      scanWidthFactor: scanWidthFactor,
      scanHeightFactor: scanHeightFactor,
    );

    onDetected?.call(detection.contentType);

    final processedBytes = await _imageProcessingService.process(
      file.path,
      contentType: detection.contentType,
      faceBoxes: detection.faceBoxes,
      textBounds: detection.textBounds,
    );

    final now = DateTime.now();
    final timestamp =
        '${now.year}${_two(now.month)}${_two(now.day)}_${_two(now.hour)}${_two(now.minute)}${_two(now.second)}';

    final processedFile = await _storageService.saveBytes(
      processedBytes,
      type: detection.contentType == ContentType.face
          ? StorageType.face
          : StorageType.document,
      filename: '${detection.contentType.name}_$timestamp.jpg',
    );

    String? pdfPath;
    if (detection.contentType == ContentType.document) {
      List<int> pdfBytes;
      if (detection.extractedText != null &&
          detection.extractedText!.trim().isNotEmpty) {
        try {
          pdfBytes = await _pdfService.buildFromText(
            detection.extractedText!,
          );
        } catch (_) {
          pdfBytes = await _pdfService.buildFromImage(processedBytes);
        }
      } else {
        pdfBytes = await _pdfService.buildFromImage(processedBytes);
      }
      final pdfFile = await _storageService.saveBytes(
        Uint8List.fromList(pdfBytes),
        type: StorageType.pdf,
        filename: 'document_$timestamp.pdf',
      );
      pdfPath = pdfFile.path;
    }

    final title =
        detection.contentType == ContentType.face ? faceTitle : documentTitle;
    final resultWithTitle = ProcessingResult(
      originalPath: imagePath,
      processedImagePath: processedFile.path,
      contentType: detection.contentType,
      title: title,
      pdfPath: pdfPath,
      extractedText: detection.extractedText,
    );

    await _repository.addHistoryItem(
      _historyMapper.toData(
        HistoryEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          type: detection.contentType,
          title: resultWithTitle.title,
          createdAt: DateTime.now(),
          originalPath: resultWithTitle.originalPath,
          processedPath: resultWithTitle.processedImagePath,
          thumbnailPath: resultWithTitle.processedImagePath,
          pdfPath: resultWithTitle.pdfPath,
          extractedText: resultWithTitle.extractedText,
        ),
      ),
    );

    return _resultMapper.toDomain(resultWithTitle);
  }

  Future<void> dispose() async {
    await _workflowService.dispose();
  }
}
