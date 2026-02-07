import 'package:get/get.dart';

import '/app/bindings/repository_bindings.dart';
import '/app/data/repository/history_repository.dart';
import '/app/modules/processing/controllers/processing_controller.dart';

class ProcessingBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HistoryRepository>()) {
      RepositoryBindings().dependencies();
    }
    Get.lazyPut<ProcessingController>(() => ProcessingController());
  }
}
