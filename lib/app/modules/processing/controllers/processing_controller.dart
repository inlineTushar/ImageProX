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

enum ContentType { face, document }

class ProcessingController extends BaseController {
  final RxString _currentStep = 'Analyzing image...'.obs;
  final Rx<ContentType?> _contentType = Rx<ContentType?>(null);
  final VisionService _visionService = VisionService();
  final ProcessingService _processingService = ProcessingService();
  final HistoryRepository _repository =
      Get.find(tag: 'HistoryRepository');

  File? _inputFile;

  String get currentStep => _currentStep.value;
  ContentType? get contentType => _contentType.value;

  void updateStep(String value) => _currentStep(value);

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is String && arg.isNotEmpty) {
      _inputFile = File(arg);
      _processImage();
    } else {
      showError('No image selected for processing.');
    }
  }

  Future<void> _processImage() async {
    final file = _inputFile;
    if (file == null) return;

    setPageState(PageState.loading);
    updateStep('Detecting content...');

    try {
      final type = await _detectContent(file)
          .timeout(const Duration(seconds: 12), onTimeout: () {
        throw TimeoutException('Detection timed out. Please try again.');
      });

      _contentType(type);
      updateStep(type == ContentType.face
          ? 'Processing face image...'
          : 'Processing document image...');

      final result = await _processingService.process(
        file.path,
        contentType: type,
      );

      setPageState(PageState.success);
      updateStep('Preparing result...');

      await _repository.addHistoryItem(
        HistoryItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          type: type == ContentType.face ? HistoryType.face : HistoryType.document,
          title: result.title,
          createdAt: DateTime.now(),
          originalPath: result.originalPath,
          processedPath: result.processedImagePath,
          thumbnailPath: result.processedImagePath,
          pdfPath: result.pdfPath,
        ),
      );

      if (result.contentType == ContentType.document) {
        Get.offNamed(Routes.PDF_CREATED, arguments: result);
      } else {
        Get.offNamed(Routes.RESULT, arguments: result);
      }
    } catch (error) {
      showError(error.toString());
      updateStep('Processing failed. Please try again.');
      setPageState(PageState.error);
    }
  }

  Future<ContentType> _detectContent(File file) async {
    final faces = await _visionService.detectFaces(file);
    if (faces.isNotEmpty) {
      return ContentType.face;
    }

    final text = await _visionService.recognizeText(file);
    return text.blocks.isNotEmpty ? ContentType.document : ContentType.document;
  }

  @override
  void onClose() {
    _visionService.dispose();
    super.onClose();
  }
}
