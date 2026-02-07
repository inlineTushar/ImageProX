import 'package:get/get.dart';

import '/app/bindings/repository_bindings.dart';
import '/app/data/repository/history_repository.dart';
import '/app/modules/home/controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HistoryRepository>()) {
      RepositoryBindings().dependencies();
    }
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
