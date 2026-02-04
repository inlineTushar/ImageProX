import 'package:get/get.dart';

import '/app/modules/capture/controllers/capture_controller.dart';

class CaptureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CaptureController>(() => CaptureController());
  }
}
