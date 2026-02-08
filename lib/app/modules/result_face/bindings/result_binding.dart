import 'package:get/get.dart';

import '/app/modules/result_face/controllers/result_controller.dart';

class ResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResultController>(() => ResultController());
  }
}
