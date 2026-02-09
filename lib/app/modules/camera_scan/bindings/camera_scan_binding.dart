import 'package:get/get.dart';

import '/app/modules/camera_scan/controllers/camera_scan_controller.dart';

class CameraScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CameraScanController>(() => CameraScanController());
  }
}
