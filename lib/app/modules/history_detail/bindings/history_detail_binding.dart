import 'package:get/get.dart';

import '/app/modules/history_detail/controllers/history_detail_controller.dart';

class HistoryDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryDetailController>(() => HistoryDetailController());
  }
}
