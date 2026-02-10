import 'package:get/get.dart';

import '/app/core/base/base_controller.dart';
import '/app/data/models/processing_result.dart';

class ResultDocumentController extends BaseController {
  ProcessingResult? get result => Get.arguments as ProcessingResult?;
}
