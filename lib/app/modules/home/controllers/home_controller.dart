import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '/app/core/base/base_controller.dart';
import '/app/data/repository/history_repository.dart';
import '/app/data/models/history_item.dart';
import '/app/data/models/content_type.dart';
import '/app/routes/app_pages.dart';
import '/app/modules/processing/controllers/processing_controller.dart';
import '/app/modules/processing/views/processing_sheet.dart';
import '/app/bindings/repository_bindings.dart';
import '/l10n/app_localizations.dart';

class HomeController extends BaseController {
  HomeController({required HistoryRepository repository})
      : _repository = repository;

  final HistoryRepository _repository;

  final RxList<HistoryItem> _items = <HistoryItem>[].obs;

  List<HistoryItem> get items => _items.toList(growable: false);

  StreamSubscription<List<HistoryItem>>? _subscription;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadHistory();
    _subscription = _repository.watchHistory().listen((items) {
      _items.assignAll(items);
    });
  }

  void loadHistory() {
    final data = _repository.loadHistory();
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
    if (!Get.isRegistered<HistoryRepository>()) {
      RepositoryBindings().dependencies();
    }
    if (Get.isRegistered<ProcessingController>()) {
      Get.delete<ProcessingController>();
    }
    Get.put(
      ProcessingController(
        repository: _repository,
      ),
      permanent: false,
    ).onInitWithImage(
      imagePath,
      forcedType: forcedType,
      scanWidthFactor: scanWidthFactor,
      scanHeightFactor: scanHeightFactor,
    );

    Get.bottomSheet(
      const ProcessingSheet(),
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
