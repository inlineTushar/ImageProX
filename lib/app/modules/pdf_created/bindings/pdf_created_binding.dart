import 'package:get/get.dart';

import '/app/modules/pdf_created/controllers/pdf_created_controller.dart';

class PdfCreatedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PdfCreatedController>(() => PdfCreatedController());
  }
}
