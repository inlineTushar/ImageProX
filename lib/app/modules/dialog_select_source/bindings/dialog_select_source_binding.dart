import 'package:get/get.dart';

import '/app/modules/dialog_select_source/controllers/dialog_select_source_controller.dart';

class DialogSelectSourceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DialogSelectSourceController>(() => DialogSelectSourceController());
  }
}
