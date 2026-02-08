import 'package:get/get.dart';

import '/app/modules/capture/bindings/capture_binding.dart';
import '/app/modules/capture/views/capture_view.dart';
import '/app/modules/home/bindings/home_binding.dart';
import '/app/modules/home/views/home_view.dart';
import '/app/modules/result_document/bindings/pdf_created_binding.dart';
import '/app/modules/result_document/views/pdf_created_view.dart';
import '/app/modules/processing/bindings/processing_binding.dart';
import '/app/modules/processing/views/processing_view.dart';
import '/app/modules/result_face/bindings/result_binding.dart';
import '/app/modules/result_face/views/result_view.dart';

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
      name: _Paths.CAPTURE,
      page: () => const CaptureView(),
      binding: CaptureBinding(),
    ),
    GetPage(
      name: _Paths.PROCESSING,
      page: () => const ProcessingView(),
      binding: ProcessingBinding(),
    ),
    GetPage(
      name: _Paths.RESULT,
      page: () => const ResultView(),
      binding: ResultBinding(),
    ),
    GetPage(
      name: _Paths.PDF_CREATED,
      page: () => const PdfCreatedView(),
      binding: PdfCreatedBinding(),
    ),
  ];
}
