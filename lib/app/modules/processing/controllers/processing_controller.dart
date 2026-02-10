import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';

import '/app/core/base/base_controller.dart';
import '/app/core/model/page_state.dart';
import '/app/data/models/content_type.dart';
import '/app/domain/entities/processed_result.dart';
import '/app/domain/usecases/process_image_use_case.dart';
import '/l10n/app_localizations.dart';

class ProcessingController extends BaseController {
  ProcessingController({
    required ProcessImageUseCase processImageUseCase,
  }) : _processImageUseCase = processImageUseCase;

  final RxString _currentStep = 'Analyzing image...'.obs;
  final Rx<ContentType?> _contentType = Rx<ContentType?>(null);
  final Rx<ProcessedResult?> _result = Rx<ProcessedResult?>(null);
  final ProcessImageUseCase _processImageUseCase;

  String? _imagePath;
  ContentType? _forcedType;
  double? _scanWidthFactor;
  double? _scanHeightFactor;

  String get currentStep => _currentStep.value;
  ContentType? get contentType => _contentType.value;
  ProcessedResult? get result => _result.value;

  void updateStep(String value) => _currentStep(value);

  Future<void> retry() async {
    _processImage();
  }

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is String && arg.isNotEmpty) {
      _imagePath = arg;
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
    _imagePath = imagePath;
    _forcedType = forcedType;
    _scanWidthFactor = scanWidthFactor;
    _scanHeightFactor = scanHeightFactor;
    _processImage();
  }

  Future<void> _processImage() async {
    final imagePath = _imagePath;
    if (imagePath == null || imagePath.isEmpty) return;

    setPageState(PageState.loading);
    updateStep(AppLocalizations.of(Get.context!)!.processingDetecting);

    try {
      final timeoutMessage =
          AppLocalizations.of(Get.context!)!.processingTimeout;
      final result = await _processImageUseCase
          .run(
            imagePath,
            forcedType: _forcedType,
            scanWidthFactor: _scanWidthFactor,
            scanHeightFactor: _scanHeightFactor,
            faceTitle: AppLocalizations.of(Get.context!)!.faceProcessed,
            documentTitle: AppLocalizations.of(Get.context!)!.documentScan,
            onDetected: (type) {
              _contentType(type);
              updateStep(type == ContentType.face
                  ? AppLocalizations.of(Get.context!)!.processingFace
                  : AppLocalizations.of(Get.context!)!.processingDocument);
            },
          )
          .timeout(const Duration(seconds: 12), onTimeout: () {
        throw TimeoutException(timeoutMessage);
      });

      setPageState(PageState.success);
      updateStep(AppLocalizations.of(Get.context!)!.processingPreparing);
      _result(result);
    } catch (error) {
      showError(error.toString());
      updateStep(AppLocalizations.of(Get.context!)!.processingFailed);
      setPageState(PageState.error);
    }
  }

  @override
  void onClose() {
    _processImageUseCase.dispose();
    super.onClose();
  }
}
