import 'dart:async';

import 'package:get/get.dart';

import '/app/core/base/base_controller.dart';
import '/app/data/repository/history_repository.dart';
import '/app/modules/home/models/history_item.dart';

class HomeController extends BaseController {
  final HistoryRepository _repository =
      Get.find(tag: 'HistoryRepository');

  final RxList<HistoryItem> _items = <HistoryItem>[].obs;

  List<HistoryItem> get items => _items.toList(growable: false);

  StreamSubscription<List<HistoryItem>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
    _subscription = _repository.watchHistory().listen((items) {
      _items.assignAll(items);
    });
  }

  void loadHistory() {
    final data = _repository.loadHistory();
    _items.assignAll(data);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
