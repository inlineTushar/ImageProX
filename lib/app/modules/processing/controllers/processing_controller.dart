import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';

import '/app/core/base/base_controller.dart';
import '/app/core/model/page_state.dart';
import '/app/data/services/processing_service.dart';
import '/app/data/services/vision_service.dart';
import '/app/data/repository/history_repository.dart';
import '/app/modules/home/models/history_item.dart';
import '/app/modules/processing/models/processing_result.dart';
import '/app/routes/app_pages.dart';
import '/l10n/app_localizations.dart';

enum ContentType { face, document }

class ProcessingController extends BaseController {
  final RxString _currentStep = 'Analyzing image...'.obs;
  final Rx<ContentType?> _contentType = Rx<ContentType?>(null);
  final VisionService _visionService = VisionService();
  final ProcessingService _processingService = ProcessingService();
  final HistoryRepository _repository = Get.find<HistoryRepository>();

  File? _inputFile;
  ContentType? _forcedType;

  String get currentStep => _currentStep.value;
  ContentType? get contentType => _contentType.value;

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

  void onInitWithImage(String imagePath, {ContentType? forcedType}) {
    _inputFile = File(imagePath);
    _forcedType = forcedType;
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
      final detection = _forcedType == null
          ? await _detectContent(file)
              .timeout(const Duration(seconds: 12), onTimeout: () {
              throw TimeoutException(timeoutMessage);
            })
          : await _detectForType(file, _forcedType!);

      _contentType(detection.contentType);
      updateStep(detection.contentType == ContentType.face
          ? AppLocalizations.of(Get.context!)!.processingFace
          : AppLocalizations.of(Get.context!)!.processingDocument);

      final result = await _processingService.process(
        file.path,
        contentType: detection.contentType,
        faceBoxes: detection.faceBoxes,
        textBounds: detection.textBounds,
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
        ),
      );

      if (resultWithTitle.contentType == ContentType.document) {
        if (Get.isBottomSheetOpen ?? false) {
          Get.back();
        }
        Get.offNamed(Routes.RESULT_DOCUMENT, arguments: resultWithTitle);
      } else {
        if (Get.isBottomSheetOpen ?? false) {
          Get.back();
        }
        Get.offNamed(Routes.RESULT_FACE, arguments: resultWithTitle);
      }
    } catch (error) {
      showError(error.toString());
      updateStep(AppLocalizations.of(Get.context!)!.processingFailed);
      setPageState(PageState.error);
    }
  }

  Future<_DetectionResult> _detectContent(File file) async {
    final faces = await _visionService.detectFaces(file);
    if (faces.isNotEmpty) {
      final boxes = faces
          .map((face) => [
                face.boundingBox.left,
                face.boundingBox.top,
                face.boundingBox.right,
                face.boundingBox.bottom,
              ])
          .toList(growable: false);
      return _DetectionResult(
        contentType: ContentType.face,
        faceBoxes: boxes,
        textBounds: const [],
      );
    }

    final text = await _visionService.recognizeText(file);
    final bounds = _visionService.computeTextBounds(text);
    final textBounds = bounds == null
        ? const <double>[]
        : [
            bounds.left,
            bounds.top,
            bounds.right,
            bounds.bottom,
          ];
    return _DetectionResult(
      contentType: ContentType.document,
      faceBoxes: const [],
      textBounds: textBounds,
    );
  }

  Future<_DetectionResult> _detectForType(
    File file,
    ContentType type,
  ) async {
    if (type == ContentType.face) {
      final faces = await _visionService.detectFaces(file);
      final boxes = faces
          .map((face) => [
                face.boundingBox.left,
                face.boundingBox.top,
                face.boundingBox.right,
                face.boundingBox.bottom,
              ])
          .toList(growable: false);
      return _DetectionResult(
        contentType: ContentType.face,
        faceBoxes: boxes,
        textBounds: const [],
      );
    }

    final text = await _visionService.recognizeText(file);
    final bounds = _visionService.computeTextBounds(text);
    final textBounds = bounds == null
        ? const <double>[]
        : [
            bounds.left,
            bounds.top,
            bounds.right,
            bounds.bottom,
          ];
    return _DetectionResult(
      contentType: ContentType.document,
      faceBoxes: const [],
      textBounds: textBounds,
    );
  }

  @override
  void onClose() {
    _visionService.dispose();
    super.onClose();
  }
}

class _DetectionResult {
  const _DetectionResult({
    required this.contentType,
    required this.faceBoxes,
    required this.textBounds,
  });

  final ContentType contentType;
  final List<List<double>> faceBoxes;
  final List<double> textBounds;
}
