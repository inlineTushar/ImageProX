import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '/app/core/base/base_controller.dart';
import '/app/data/models/content_type.dart';
import '/app/domain/entities/history_entry.dart';
import '/app/domain/usecases/history_use_case.dart';
import '/app/domain/usecases/process_image_use_case.dart';
import '/app/routes/app_pages.dart';
import '/app/modules/processing/controllers/processing_controller.dart';
import '/app/modules/processing/views/processing_sheet.dart';
import '/app/bindings/repository_bindings.dart';
import '/l10n/app_localizations.dart';

class HomeController extends BaseController {
  HomeController({
    required HistoryUseCase historyUseCase,
    required ProcessImageUseCase processImageUseCase,
  })  : _historyUseCase = historyUseCase,
        _processImageUseCase = processImageUseCase;

  final HistoryUseCase _historyUseCase;
  final ProcessImageUseCase _processImageUseCase;

  final RxList<HistoryEntry> _items = <HistoryEntry>[].obs;

  List<HistoryEntry> get items => _items.toList(growable: false);

  StreamSubscription<List<HistoryEntry>>? _subscription;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadHistory();
    _subscription = _historyUseCase.watchHistory().listen((items) {
      _items.assignAll(items);
    });
  }

  void loadHistory() {
    final data = _historyUseCase.loadHistory();
    _items.assignAll(data);
  }

  Future<void> onCameraSelected() async {
    final granted = await _requestCameraPermission();
    if (!granted) {
      showError(AppLocalizations.of(Get.context!)!.cameraPermissionDenied);
      return;
    }

    Get.back();
    final result = await Get.toNamed(Routes.CAMERA_SCAN);
    if (result is! Map) return;
    final imagePath = result['path'] as String?;
    final scanWidth = result['scanWidthFactor'] as double?;
    final scanHeight = result['scanHeightFactor'] as double?;
    if (imagePath == null || imagePath.isEmpty) return;
    _openProcessingSheet(
      imagePath,
      scanWidthFactor: scanWidth,
      scanHeightFactor: scanHeight,
    );
  }

  Future<void> onGallerySelected() async {
    final granted = await _requestGalleryPermission();
    if (!granted) {
      showError(AppLocalizations.of(Get.context!)!.galleryPermissionDenied);
      return;
    }

    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    Get.back();
    _openProcessingSheet(image.path);
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> _requestGalleryPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted || status.isLimited;
    }

    if (Platform.isAndroid) {
      final photosStatus = await Permission.photos.request();
      if (photosStatus.isGranted) return true;

      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }

    final status = await Permission.storage.request();
    return status.isGranted;
  }

  void _openProcessingSheet(
    String imagePath, {
    ContentType? forcedType,
    double? scanWidthFactor,
    double? scanHeightFactor,
  }) {
    if (Get.isRegistered<ProcessingController>()) {
      Get.delete<ProcessingController>();
    }
    final controller = Get.put(
      ProcessingController(
        processImageUseCase: _processImageUseCase,
      ),
      permanent: false,
    );
    controller.onInitWithImage(
      imagePath,
      forcedType: forcedType,
      scanWidthFactor: scanWidthFactor,
      scanHeightFactor: scanHeightFactor,
    );

    Get.bottomSheet(
      ProcessingSheet(controller: controller),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
    );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
