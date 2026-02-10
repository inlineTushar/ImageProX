import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:imageprox/app/data/models/content_type.dart';
import 'package:imageprox/app/data/models/history_item.dart';
import 'package:imageprox/app/data/services/processing_workflow_service.dart';
import 'package:imageprox/app/data/services/storage_service.dart';
import 'package:imageprox/app/domain/failures/failure.dart';
import 'package:imageprox/app/domain/repositories/history_repository.dart';
import 'package:imageprox/app/domain/services/image_processing_service.dart';
import 'package:imageprox/app/domain/services/pdf_service.dart';
import 'package:imageprox/app/domain/services/storage_service.dart';
import 'package:imageprox/app/domain/usecases/process_image_use_case.dart';

class _MockHistoryRepository extends Mock implements HistoryRepository {}
class _MockImageProcessingService extends Mock implements ImageProcessingService {}
class _MockPdfService extends Mock implements PdfService {}
class _MockStorageService extends Mock implements StorageService {}
class _MockWorkflowService extends Mock implements ProcessingWorkflowService {}

void main() {
  setUpAll(() {
    registerFallbackValue(File('test.jpg'));
    registerFallbackValue(<int>[]);
    registerFallbackValue(Uint8List.fromList([1, 2, 3]));
    registerFallbackValue(ContentType.face);
    registerFallbackValue(StorageType.face);
    registerFallbackValue(
      HistoryItem(
        id: 'x',
        type: HistoryType.face,
        title: 't',
        createdAt: DateTime(2024),
        originalPath: '/o',
        processedPath: '/p',
      ),
    );
  });

  group('ProcessImageUseCase', () {
    late HistoryRepository repository;
    late ImageProcessingService imageProcessing;
    late PdfService pdfService;
    late StorageService storageService;
    late ProcessingWorkflowService workflow;
    late ProcessImageUseCase useCase;

    setUp(() {
      repository = _MockHistoryRepository();
      imageProcessing = _MockImageProcessingService();
      pdfService = _MockPdfService();
      storageService = _MockStorageService();
      workflow = _MockWorkflowService();

      useCase = ProcessImageUseCase(
        repository: repository,
        imageProcessingService: imageProcessing,
        pdfService: pdfService,
        storageService: storageService,
        workflowService: workflow,
      );
    });

    test('processes document with OCR text', () async {
      when(() => workflow.detectContent(
            any<File>(),
            forcedType: any(named: 'forcedType'),
            scanWidthFactor: any(named: 'scanWidthFactor'),
            scanHeightFactor: any(named: 'scanHeightFactor'),
          )).thenAnswer(
        (_) async => const DetectionResult(
          contentType: ContentType.document,
          faceBoxes: [],
          textBounds: [0, 0, 10, 10],
          extractedText: 'hello',
        ),
      );
      when(() => imageProcessing.process(
            any(),
            contentType: any(named: 'contentType'),
            faceBoxes: any(named: 'faceBoxes'),
            textBounds: any(named: 'textBounds'),
          )).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));
      when(() => pdfService.buildFromText(any()))
          .thenAnswer((_) async => [1, 2, 3, 4]);
      when(() => storageService.saveBytes(
            any(),
            type: any(named: 'type'),
            filename: any(named: 'filename'),
          )).thenAnswer((_) async => File('/tmp/file'));
      when(() => repository.addHistoryItem(any()))
          .thenAnswer((_) async => {});

      final result = await useCase.run(
        '/tmp/input.jpg',
        faceTitle: 'Face',
        documentTitle: 'Doc',
      );

      expect(result.contentType, ContentType.document);
      expect(result.title, 'Doc');
      verify(() => pdfService.buildFromText('hello')).called(1);
    });

    test('throws OcrFailure when text PDF generation fails', () async {
      when(() => workflow.detectContent(
            any<File>(),
            forcedType: any(named: 'forcedType'),
            scanWidthFactor: any(named: 'scanWidthFactor'),
            scanHeightFactor: any(named: 'scanHeightFactor'),
          )).thenAnswer(
        (_) async => const DetectionResult(
          contentType: ContentType.document,
          faceBoxes: [],
          textBounds: [0, 0, 10, 10],
          extractedText: 'text',
        ),
      );
      when(() => imageProcessing.process(
            any(),
            contentType: any(named: 'contentType'),
            faceBoxes: any(named: 'faceBoxes'),
            textBounds: any(named: 'textBounds'),
          )).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));
      when(() => pdfService.buildFromText(any()))
          .thenThrow(Exception('pdf fail'));
      when(() => storageService.saveBytes(
            any(),
            type: any(named: 'type'),
            filename: any(named: 'filename'),
          )).thenAnswer((_) async => File('/tmp/file'));
      when(() => repository.addHistoryItem(any()))
          .thenAnswer((_) async => {});

      expect(
        () => useCase.run(
          '/tmp/input.jpg',
          faceTitle: 'Face',
          documentTitle: 'Doc',
        ),
        throwsA(isA<OcrFailure>()),
      );
    });
  });
}
