import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';

import '/app/core/base/base_view.dart';
import '/app/core/values/app_values.dart';
import '/app/modules/result_document/controllers/result_document_controller.dart';
import '/app/modules/result_document/views/pdf_fullscreen_view.dart';
import '/app/routes/app_pages.dart';
import '/l10n/app_localizations.dart';

class ResultDocumentView extends BaseView<ResultDocumentController> {
  const ResultDocumentView({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return AppBar(
      title: Text(strings.pdfCreatedTitle),
      backgroundColor: const Color(0xFF1C1B24),
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Get.offAllNamed(Routes.HOME),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final result = controller.result;
    final title = '';
    final pdfPath = result?.pdfPath;

    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(Routes.HOME);
        return false;
      },
      child: Container(
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
                      _PdfPreview(path: pdfPath),
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
              Get.to(() => PdfFullscreenView(filePath: path));
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  Color statusBarColor() => const Color(0xFF1C1B24);
}

class _PdfPreview extends StatefulWidget {
  const _PdfPreview({required this.path});

  final String? path;

  @override
  State<_PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<_PdfPreview> {
  PdfDocument? _document;

  @override
  void didUpdateWidget(covariant _PdfPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _document?.close();
      _document = null;
    }
  }

  @override
  void dispose() {
    _document?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.path;
    if (path == null || path.isEmpty || !File(path).existsSync()) {
      return _previewFallback();
    }

    return FutureBuilder<PdfPageImage>(
      future: _loadFirstPage(path),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _previewFallback();
        }
        final pageImage = snapshot.data!;
        return Container(
          height: 420,
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              pageImage.bytes,
              fit: BoxFit.contain,
              gaplessPlayback: true,
            ),
          ),
        );
      },
    );
  }

  Future<PdfPageImage> _loadFirstPage(String path) async {
    _document ??= await PdfDocument.openFile(path);
    final page = await _document!.getPage(1);
    final image = await page.render(
      width: 240,
      height: 320,
      format: PdfPageImageFormat.png,
      backgroundColor: '#FFFFFF',
    );
    await page.close();
    if (image == null) {
      throw Exception('Failed to render PDF preview');
    }
    return image;
  }

  Widget _previewFallback() {
    return Container(
      height: 420,
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
    );
  }
}
