import 'package:get/get.dart';

import '/app/core/base/base_controller.dart';
import '/app/modules/home/models/history_item.dart';

class HistoryDetailController extends BaseController {
  HistoryItem? get item => Get.arguments as HistoryItem?;
}
