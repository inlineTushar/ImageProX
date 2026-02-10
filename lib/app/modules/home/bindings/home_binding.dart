import 'package:get/get.dart';

import '/app/bindings/repository_bindings.dart';
import '/app/data/repository/history_repository.dart';
import '/app/domain/usecases/history_use_case.dart';
import '/app/domain/usecases/process_image_use_case.dart';
import '/app/modules/home/controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HistoryRepository>()) {
      RepositoryBindings().dependencies();
    }
    Get.lazyPut<HistoryUseCase>(
      () => HistoryUseCase(
        repository: Get.find<HistoryRepository>(),
      ),
    );
    Get.lazyPut<ProcessImageUseCase>(
      () => ProcessImageUseCase(
        repository: Get.find<HistoryRepository>(),
      ),
    );
    Get.lazyPut<HomeController>(
      () => HomeController(
        historyUseCase: Get.find<HistoryUseCase>(),
        processImageUseCase: Get.find<ProcessImageUseCase>(),
      ),
    );
  }
}
