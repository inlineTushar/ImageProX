import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';

import '/app/core/base/base_view.dart';
import '/app/core/values/app_values.dart';
import '/app/modules/result_document/controllers/pdf_created_controller.dart';
import '/app/routes/app_pages.dart';
import '/l10n/app_localizations.dart';

class PdfCreatedView extends BaseView<PdfCreatedController> {
  const PdfCreatedView({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return AppBar(
      title: Text(strings.pdfCreatedTitle),
      backgroundColor: const Color(0xFF1C1B24),
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final result = controller.result;
    final title =
        result?.title ?? AppLocalizations.of(context)!.documentTitle;

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
                controller.showError(
                    AppLocalizations.of(context)!.pdfUnavailable);
                return;
              }
              await OpenFilex.open(path);
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: Text(AppLocalizations.of(context)!.openPdf),
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
            child: Text(AppLocalizations.of(context)!.done),
          ),
        ],
      ),
    ),
    );
  }

  @override
  Color statusBarColor() => const Color(0xFF1C1B24);
}
