import 'package:get/get.dart';

import '/app/modules/dialog_select_source/controllers/capture_controller.dart';

class CaptureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CaptureController>(() => CaptureController());
  }
}
