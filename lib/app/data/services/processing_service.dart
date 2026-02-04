import 'dart:io';

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
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Unable to decode image');
    }

    final now = DateTime.now();
    final timestamp =
        '${now.year}${_two(now.month)}${_two(now.day)}_${_two(now.hour)}${_two(now.minute)}${_two(now.second)}';

    final processed = _applyProcessing(decoded, contentType);
    final processedFile = await _storageService.saveBytes(
      img.encodeJpg(processed, quality: 90),
      type: contentType == ContentType.face
          ? StorageType.face
          : StorageType.document,
      filename: '${contentType.name}_$timestamp.jpg',
    );

    String? pdfPath;
    if (contentType == ContentType.document) {
      final pdfBytes = await _buildPdf(processed);
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

  Future<List<int>> _buildPdf(img.Image image) async {
    final pdf = pw.Document();
    final pdfImage = pw.MemoryImage(img.encodeJpg(image, quality: 90));

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
