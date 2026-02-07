part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const HOME = _Paths.HOME;
  static const CAPTURE = _Paths.CAPTURE;
  static const PROCESSING = _Paths.PROCESSING;
  static const RESULT = _Paths.RESULT;
  static const HISTORY_DETAIL = _Paths.HISTORY_DETAIL;
  static const PDF_CREATED = _Paths.PDF_CREATED;
}

abstract class _Paths {
  static const HOME = '/home';
  static const CAPTURE = '/capture';
  static const PROCESSING = '/processing';
  static const RESULT = '/result';
  static const HISTORY_DETAIL = '/history-detail';
  static const PDF_CREATED = '/pdf-created';
}
