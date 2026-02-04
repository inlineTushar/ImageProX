import 'dart:io';

import 'package:get/get.dart';

import '/app/core/base/base_controller.dart';
import '/app/data/services/vision_service.dart';

enum ContentType { face, document }

class ProcessingController extends BaseController {
  final RxString _currentStep = 'Analyzing image...'.obs;
  final Rx<ContentType?> _contentType = Rx<ContentType?>(null);
  final VisionService _visionService = VisionService();

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

    await runTask(
      _detectContent(file),
      onStart: () => updateStep('Detecting content...'),
      onSuccess: (type) {
        _contentType(type);
        if (type == ContentType.face) {
          updateStep('Face processing in progress...');
        } else {
          updateStep('Document processing in progress...');
        }
      },
      onComplete: () => updateStep('Preparing result...'),
    );
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
