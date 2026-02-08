import 'package:get/get.dart';

import '/app/modules/result_face/controllers/result_face_controller.dart';

class ResultFaceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResultFaceController>(() => ResultFaceController());
  }
}
