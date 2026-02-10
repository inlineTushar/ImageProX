import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';

import '/app/core/base/base_controller.dart';
import '/app/core/model/page_state.dart';
import '/app/data/models/content_type.dart';
import '/app/data/services/processing_service.dart';
import '/app/data/services/processing_workflow_service.dart';
import '/app/data/repository/history_repository.dart';
import '/app/data/models/history_item.dart';
import '/app/modules/processing/models/processing_result.dart';
import '/l10n/app_localizations.dart';

class ProcessingController extends BaseController {
  ProcessingController({
    required HistoryRepository repository,
    ProcessingService? processingService,
    ProcessingWorkflowService? workflowService,
  })  : _processingService = processingService ?? ProcessingService(),
        _workflowService = workflowService ?? ProcessingWorkflowService(),
        _repository = repository;

  final RxString _currentStep = 'Analyzing image...'.obs;
  final Rx<ContentType?> _contentType = Rx<ContentType?>(null);
  final Rx<ProcessingResult?> _result = Rx<ProcessingResult?>(null);
  final ProcessingService _processingService;
  final ProcessingWorkflowService _workflowService;
  final HistoryRepository _repository;

  File? _inputFile;
  ContentType? _forcedType;
  double? _scanWidthFactor;
  double? _scanHeightFactor;

  String get currentStep => _currentStep.value;
  ContentType? get contentType => _contentType.value;
  ProcessingResult? get result => _result.value;

  void updateStep(String value) => _currentStep(value);

  Future<void> retry() async {
    _processImage();
  }

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is String && arg.isNotEmpty) {
      _inputFile = File(arg);
      _processImage();
    } else {
      showError(AppLocalizations.of(Get.context!)!.noImageSelected);
    }
  }

  void onInitWithImage(
    String imagePath, {
    ContentType? forcedType,
    double? scanWidthFactor,
    double? scanHeightFactor,
  }) {
    _inputFile = File(imagePath);
    _forcedType = forcedType;
    _scanWidthFactor = scanWidthFactor;
    _scanHeightFactor = scanHeightFactor;
    _processImage();
  }

  Future<void> _processImage() async {
    final file = _inputFile;
    if (file == null) return;

    setPageState(PageState.loading);
    updateStep(AppLocalizations.of(Get.context!)!.processingDetecting);

    try {
      final timeoutMessage =
          AppLocalizations.of(Get.context!)!.processingTimeout;
      final detection = await _workflowService
          .detectContent(
            file,
            forcedType: _forcedType,
            scanWidthFactor: _scanWidthFactor,
            scanHeightFactor: _scanHeightFactor,
          )
          .timeout(const Duration(seconds: 12), onTimeout: () {
        throw TimeoutException(timeoutMessage);
      });

      _contentType(detection.contentType);
      updateStep(detection.contentType == ContentType.face
          ? AppLocalizations.of(Get.context!)!.processingFace
          : AppLocalizations.of(Get.context!)!.processingDocument);

      final result = await _processingService.process(
        file.path,
        contentType: detection.contentType,
        faceBoxes: detection.faceBoxes,
        textBounds: detection.textBounds,
        extractedText: detection.extractedText,
      );

      setPageState(PageState.success);
      updateStep(AppLocalizations.of(Get.context!)!.processingPreparing);

      final localizedTitle = detection.contentType == ContentType.face
          ? AppLocalizations.of(Get.context!)!.faceProcessed
          : AppLocalizations.of(Get.context!)!.documentScan;
      final resultWithTitle = ProcessingResult(
        originalPath: result.originalPath,
        processedImagePath: result.processedImagePath,
        contentType: result.contentType,
        title: localizedTitle,
        pdfPath: result.pdfPath,
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

      _result(resultWithTitle);
    } catch (error) {
      showError(error.toString());
      updateStep(AppLocalizations.of(Get.context!)!.processingFailed);
      setPageState(PageState.error);
    }
  }

  @override
  void onClose() {
    _workflowService.dispose();
    super.onClose();
  }
}
