import 'package:get/get.dart';

import '/app/modules/result_document/controllers/result_document_controller.dart';

class ResultDocumentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResultDocumentController>(() => ResultDocumentController());
  }
}
