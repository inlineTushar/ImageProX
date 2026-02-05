import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';

import '/app/core/base/base_view.dart';
import '/app/core/values/app_values.dart';
import '/app/modules/pdf_created/controllers/pdf_created_controller.dart';
import '/app/routes/app_pages.dart';

class PdfCreatedView extends BaseView<PdfCreatedController> {
  const PdfCreatedView({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('PDF Created'),
      backgroundColor: const Color(0xFF1C1B24),
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final result = controller.result;
    final title = result?.title ?? 'Document Title';

    return Container(
      color: const Color(0xFF1C1B24),
      child: Padding(
      padding: const EdgeInsets.all(AppValues.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 120,
                    width: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2230),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF4D6D),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'PDF',
                        style: TextStyle(
                          color: Color(0xFFFF4D6D),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              final path = result?.pdfPath;
              if (path == null || path.isEmpty) {
                controller.showError('PDF is not available yet.');
                return;
              }
              await OpenFilex.open(path);
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Open PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5C72),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Get.offAllNamed(Routes.HOME),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF3B3A45)),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    ),
    );
  }

  @override
  Color statusBarColor() => const Color(0xFF1C1B24);
}
