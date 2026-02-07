import 'package:get/get.dart';

import '/app/data/repository/history_repository.dart';
import '/app/data/repository/history_repository_impl.dart';

class RepositoryBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryRepository>(
      () => HistoryRepositoryImpl(),
    );
  }
}
