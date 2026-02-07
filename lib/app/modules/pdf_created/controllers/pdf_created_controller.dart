import 'package:get/get.dart';

import '/app/core/base/base_controller.dart';
import '/app/modules/processing/models/processing_result.dart';

class PdfCreatedController extends BaseController {
  ProcessingResult? get result => Get.arguments as ProcessingResult?;
}
