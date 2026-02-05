import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '/app/data/services/storage_service.dart';
import '/app/modules/processing/controllers/processing_controller.dart';
import '/app/modules/processing/models/processing_result.dart';

class ProcessingService {
  ProcessingService({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  final StorageService _storageService;

  Future<ProcessingResult> process(
    String imagePath, {
    required ContentType contentType,
  }) async {
    final result = await compute(_processInIsolate, _ProcessPayload(
      imagePath: imagePath,
      contentType: contentType,
    ));

    final now = DateTime.now();
    final timestamp =
        '${now.year}${_two(now.month)}${_two(now.day)}_${_two(now.hour)}${_two(now.minute)}${_two(now.second)}';

    final processedFile = await _storageService.saveBytes(
      result.processedBytes,
      type: contentType == ContentType.face
          ? StorageType.face
          : StorageType.document,
      filename: '${contentType.name}_$timestamp.jpg',
    );

    final title =
        contentType == ContentType.face ? 'Face Processed' : 'Document Scan';

    String? pdfPath;
    if (contentType == ContentType.document) {
      final pdfBytes = await _buildPdf(result.processedBytes);
      final pdfFile = await _storageService.saveBytes(
        pdfBytes,
        type: StorageType.pdf,
        filename: 'document_$timestamp.pdf',
      );
      pdfPath = pdfFile.path;
    }

    return ProcessingResult(
      originalPath: imagePath,
      processedImagePath: processedFile.path,
      contentType: contentType,
      title: title,
      pdfPath: pdfPath,
    );
  }

  img.Image _applyProcessing(img.Image input, ContentType type) {
    if (type == ContentType.face) {
      return img.grayscale(input);
    }

    return img.adjustColor(
      input,
      contrast: 1.1,
      brightness: 1.05,
      saturation: 1.05,
    );
  }

  Future<List<int>> _buildPdf(Uint8List imageBytes) async {
    final pdf = pw.Document();
    final pdfImage = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Center(
            child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
          );
        },
      ),
    );

    return pdf.save();
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}

class _ProcessPayload {
  const _ProcessPayload({
    required this.imagePath,
    required this.contentType,
  });

  final String imagePath;
  final ContentType contentType;
}

class _ProcessResult {
  const _ProcessResult({
    required this.processedBytes,
  });

  final Uint8List processedBytes;
}

_ProcessResult _processInIsolate(_ProcessPayload payload) {
  final file = File(payload.imagePath);
  final bytes = file.readAsBytesSync();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw Exception('Unable to decode image');
  }

  final processed = payload.contentType == ContentType.face
      ? img.grayscale(decoded)
      : img.adjustColor(
          decoded,
          contrast: 1.1,
          brightness: 1.05,
          saturation: 1.05,
        );

  final processedBytes = Uint8List.fromList(
    img.encodeJpg(processed, quality: 90),
  );
  return _ProcessResult(processedBytes: processedBytes);
}
