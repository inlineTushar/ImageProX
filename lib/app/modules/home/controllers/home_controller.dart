import 'package:get/get.dart';

import '/app/core/base/base_controller.dart';
import '/app/data/repository/history_repository.dart';
import '/app/modules/home/models/history_item.dart';

class HomeController extends BaseController {
  final HistoryRepository _repository =
      Get.find(tag: HistoryRepository.toString());

  final RxList<HistoryItem> _items = <HistoryItem>[].obs;

  List<HistoryItem> get items => _items.toList(growable: false);

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  void loadHistory() {
    final data = _repository.loadHistory();
    _items.assignAll(data);
  }
}
