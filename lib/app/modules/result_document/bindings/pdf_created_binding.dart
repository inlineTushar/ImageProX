import 'package:get/get.dart';

import '/app/modules/result_document/controllers/pdf_created_controller.dart';

class PdfCreatedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PdfCreatedController>(() => PdfCreatedController());
  }
}
