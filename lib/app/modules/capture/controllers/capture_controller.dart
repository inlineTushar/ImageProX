import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '/app/core/base/base_controller.dart';
import '/app/routes/app_pages.dart';

class CaptureController extends BaseController {
  final ImagePicker _picker = ImagePicker();

  Future<void> selectCamera() async {
    final granted = await _requestCameraPermission();
    if (!granted) {
      showError('Camera permission denied.');
      return;
    }

    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    Get.toNamed(Routes.PROCESSING, arguments: image.path);
  }

  Future<void> selectGallery() async {
    final granted = await _requestGalleryPermission();
    if (!granted) {
      showError('Gallery permission denied.');
      return;
    }

    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    Get.toNamed(Routes.PROCESSING, arguments: image.path);
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
}
