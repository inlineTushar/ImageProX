part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const HOME = _Paths.HOME;
  static const CAMERA_SCAN = _Paths.CAMERA_SCAN;
  static const RESULT_FACE = _Paths.RESULT_FACE;
  static const RESULT_DOCUMENT = _Paths.RESULT_DOCUMENT;
}

abstract class _Paths {
  static const HOME = '/home';
  static const CAMERA_SCAN = '/camera-scan';
  static const RESULT_FACE = '/result-face';
  static const RESULT_DOCUMENT = '/result-document';
}
