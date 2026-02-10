import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

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
  double? _scanWidthFactor;
  double? _scanHeightFactor;

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
    final scanRect = await _scanWindowForFile(file);
    final faces = await _visionService.detectFaces(file);
    final filteredFaces =
        scanRect == null ? faces : faces.where((face) => _overlaps(face.boundingBox, scanRect)).toList(growable: false);
    if (filteredFaces.isNotEmpty) {
      final boxes = filteredFaces
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

    final text = await _recognizeTextWithFallback(file);
    final bounds = _computeTextBoundsForWindow(text, scanRect);
    final textBounds = bounds == null
        ? const <double>[]
        : [
            bounds.left,
            bounds.top,
            bounds.right,
            bounds.bottom,
          ];
    final extractedText = _extractTextLines(text, scanRect: scanRect);
    if (scanRect != null && extractedText.isEmpty) {
      return _DetectionResult(
        contentType: ContentType.document,
        faceBoxes: const [],
        textBounds: const [],
        extractedText: null,
      );
    }
    return _DetectionResult(
      contentType: ContentType.document,
      faceBoxes: const [],
      textBounds: textBounds,
      extractedText: extractedText.isEmpty ? null : extractedText,
    );
  }

  Future<_DetectionResult> _detectForType(
    File file,
    ContentType type,
  ) async {
    if (type == ContentType.face) {
      final scanRect = await _scanWindowForFile(file);
      final faces = await _visionService.detectFaces(file);
      final filteredFaces =
          scanRect == null ? faces : faces.where((face) => _overlaps(face.boundingBox, scanRect)).toList(growable: false);
      final boxes = filteredFaces
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

    final scanRect = await _scanWindowForFile(file);
    final text = await _recognizeTextWithFallback(file);
    final bounds = _computeTextBoundsForWindow(text, scanRect);
    final textBounds = bounds == null
        ? const <double>[]
        : [
            bounds.left,
            bounds.top,
            bounds.right,
            bounds.bottom,
          ];
    final extractedText = _extractTextLines(text, scanRect: scanRect);
    return _DetectionResult(
      contentType: ContentType.document,
      faceBoxes: const [],
      textBounds: textBounds,
      extractedText: extractedText.isEmpty ? null : extractedText,
    );
  }

  @override
  void onClose() {
    _visionService.dispose();
    super.onClose();
  }

  Future<RecognizedText> _recognizeTextWithFallback(File file) async {
    final text = await _visionService.recognizeText(file);
    final extracted = _extractTextLines(text);
    debugPrint(
      'OCR primary blocks=${text.blocks.length} extractedLen=${extracted.length}',
    );
    if (extracted.isNotEmpty) {
      return text;
    }
    final enhanced = await _visionService.recognizeTextEnhanced(file);
    final enhancedExtracted = _extractTextLines(enhanced);
    debugPrint(
      'OCR enhanced blocks=${enhanced.blocks.length} extractedLen=${enhancedExtracted.length}',
    );
    return enhanced;
  }

  String _extractTextLines(RecognizedText text, {Rect? scanRect}) {
    if (text.blocks.isEmpty) return '';

    final lines = <String>[];
    for (final block in text.blocks) {
      if (scanRect != null && !_overlaps(block.boundingBox, scanRect)) {
        continue;
      }
      if (block.lines.isEmpty) {
        final value = block.text.trim();
        if (value.isNotEmpty) {
          lines.add(value);
        }
        continue;
      }
      for (final line in block.lines) {
        if (scanRect != null && !_overlaps(line.boundingBox, scanRect)) {
          continue;
        }
        final value = line.text.trim();
        if (value.isNotEmpty) {
          lines.add(value);
        }
      }
    }

    if (lines.isEmpty) {
      final fallback = text.text.trim();
      return fallback;
    }

    return lines.join('\n').trim();
  }

  Future<Rect?> _scanWindowForFile(File file) async {
    final widthFactor = _scanWidthFactor;
    final heightFactor = _scanHeightFactor;
    if (widthFactor == null || heightFactor == null) return null;

    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    final oriented = img.bakeOrientation(decoded);
    final imageSize = Size(
      oriented.width.toDouble(),
      oriented.height.toDouble(),
    );
    final rectWidth = imageSize.width * widthFactor;
    final rectHeight = imageSize.height * heightFactor;
    final left = (imageSize.width - rectWidth) / 2;
    final top = (imageSize.height - rectHeight) / 2;
    return Rect.fromLTWH(left, top, rectWidth, rectHeight);
  }

  Rect? _computeTextBoundsForWindow(RecognizedText text, Rect? scanRect) {
    if (text.blocks.isEmpty) return null;

    double left = double.infinity;
    double top = double.infinity;
    double right = 0;
    double bottom = 0;
    var found = false;

    for (final block in text.blocks) {
      if (scanRect != null && !_overlaps(block.boundingBox, scanRect)) {
        continue;
      }
      final rect = block.boundingBox;
      left = left > rect.left ? rect.left : left;
      top = top > rect.top ? rect.top : top;
      right = right < rect.right ? rect.right : right;
      bottom = bottom < rect.bottom ? rect.bottom : bottom;
      found = true;
    }

    if (!found) return null;
    return Rect.fromLTRB(left, top, right, bottom);
  }

  bool _overlaps(Rect a, Rect b) => a.overlaps(b);
}

class _DetectionResult {
  const _DetectionResult({
    required this.contentType,
    required this.faceBoxes,
    required this.textBounds,
    this.extractedText,
  });

  final ContentType contentType;
  final List<List<double>> faceBoxes;
  final List<double> textBounds;
  final String? extractedText;
}
