part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const HOME = _Paths.HOME;
  static const SELECT_SOURCE = _Paths.SELECT_SOURCE;
  static const PROCESSING = _Paths.PROCESSING;
  static const RESULT_FACE = _Paths.RESULT_FACE;
  static const RESULT_DOCUMENT = _Paths.RESULT_DOCUMENT;
}

abstract class _Paths {
  static const HOME = '/home';
  static const SELECT_SOURCE = '/select-source';
  static const PROCESSING = '/processing';
  static const RESULT_FACE = '/result-face';
  static const RESULT_DOCUMENT = '/result-document';
}
