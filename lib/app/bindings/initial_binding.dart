import 'package:get/get.dart';

import '/app/bindings/repository_bindings.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    RepositoryBindings().dependencies();
  }
}
