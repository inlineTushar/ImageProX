import 'package:get/get.dart';

import '/app/modules/dialog_select_source/bindings/dialog_select_source_binding.dart';
import '/app/modules/dialog_select_source/views/dialog_select_source_view.dart';
import '/app/modules/home/bindings/home_binding.dart';
import '/app/modules/home/views/home_view.dart';
import '/app/modules/camera_scan/bindings/camera_scan_binding.dart';
import '/app/modules/camera_scan/views/camera_scan_view.dart';
import '/app/modules/result_document/bindings/result_document_binding.dart';
import '/app/modules/result_document/views/result_document_view.dart';
import '/app/modules/processing/bindings/processing_binding.dart';
import '/app/modules/processing/views/processing_view.dart';
import '/app/modules/result_face/bindings/result_face_binding.dart';
import '/app/modules/result_face/views/result_face_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SELECT_SOURCE,
      page: () => const DialogSelectSourceView(),
      binding: DialogSelectSourceBinding(),
    ),
    GetPage(
      name: _Paths.CAMERA_SCAN,
      page: () => const CameraScanView(),
      binding: CameraScanBinding(),
    ),
    GetPage(
      name: _Paths.PROCESSING,
      page: () => const ProcessingView(),
      binding: ProcessingBinding(),
    ),
    GetPage(
      name: _Paths.RESULT_FACE,
      page: () => const ResultFaceView(),
      binding: ResultFaceBinding(),
    ),
    GetPage(
      name: _Paths.RESULT_DOCUMENT,
      page: () => const ResultDocumentView(),
      binding: ResultDocumentBinding(),
    ),
  ];
}
