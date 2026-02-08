import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '/app/core/values/app_colors.dart';

class PdfFullscreenView extends StatefulWidget {
  const PdfFullscreenView({super.key, required this.filePath});

  final String filePath;

  @override
  State<PdfFullscreenView> createState() => _PdfFullscreenViewState();
}

class _PdfFullscreenViewState extends State<PdfFullscreenView> {
  late final PdfControllerPinch _controller;

  @override
  void initState() {
    super.initState();
    _controller = PdfControllerPinch(
      document: PdfDocument.openFile(widget.filePath),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: Colors.white,
        title: const Text('PDF'),
      ),
      body: PdfViewPinch(
        controller: _controller,
      ),
    );
  }
}
