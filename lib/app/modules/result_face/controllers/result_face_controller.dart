import 'package:get/get.dart';

import '/app/core/base/base_controller.dart';
import '/app/domain/entities/processed_result.dart';

class ResultFaceController extends BaseController {
  ProcessedResult? get result => Get.arguments as ProcessedResult?;
}
