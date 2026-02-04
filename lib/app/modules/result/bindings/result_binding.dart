import 'package:get/get.dart';

import '/app/modules/result/controllers/result_controller.dart';

class ResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResultController>(() => ResultController());
  }
}
