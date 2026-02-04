import 'package:get/get.dart';

import '/app/core/model/page_state.dart';

abstract class BaseController extends GetxController {
  final _pageState = PageState.idle.obs;
  final _message = ''.obs;
  final _errorMessage = ''.obs;

  PageState get pageState => _pageState.value;
  String get message => _message.value;
  String get errorMessage => _errorMessage.value;

  void setPageState(PageState state) => _pageState(state);
  void showMessage(String value) => _message(value);
  void showError(String value) => _errorMessage(value);
  void clearMessages() {
    _message('');
    _errorMessage('');
  }

  Future<T?> runTask<T>(
    Future<T> future, {
    void Function(T value)? onSuccess,
    void Function(Object error)? onError,
    void Function()? onStart,
    void Function()? onComplete,
  }) async {
    try {
      onStart?.call();
      setPageState(PageState.loading);

      final value = await future;
      onSuccess?.call(value);

      setPageState(PageState.success);
      onComplete?.call();
      return value;
    } catch (error) {
      showError(error.toString());
      setPageState(PageState.error);
      onError?.call(error);
      onComplete?.call();
      return null;
    }
  }

  @override
  void onClose() {
    _pageState.close();
    _message.close();
    _errorMessage.close();
    super.onClose();
  }
}
