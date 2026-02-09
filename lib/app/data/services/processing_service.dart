import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart';
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
    List<List<double>>? faceBoxes,
    List<double>? textBounds,
    String? originalPathOverride,
    String? extractedText,
  }) async {
    final result = await compute(
      _processInIsolate,
      _ProcessPayload(
        imagePath: imagePath,
        contentType: contentType,
        faceBoxes: faceBoxes ?? const [],
        textBounds: textBounds ?? const [],
      ),
    );

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

    String? pdfPath;
    if (contentType == ContentType.document) {
      List<int> pdfBytes;
      if (extractedText != null && extractedText.trim().isNotEmpty) {
        try {
          pdfBytes = await _buildPdfFromText(extractedText);
        } catch (_) {
          pdfBytes = await _buildPdf(result.processedBytes);
        }
      } else {
        pdfBytes = await _buildPdf(result.processedBytes);
      }
      final pdfFile = await _storageService.saveBytes(
        pdfBytes,
        type: StorageType.pdf,
        filename: 'document_$timestamp.pdf',
      );
      pdfPath = pdfFile.path;
    }

    return ProcessingResult(
      originalPath: originalPathOverride ?? imagePath,
      processedImagePath: processedFile.path,
      contentType: contentType,
      title: contentType.name,
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

  Future<List<int>> _buildPdfFromText(String text) async {
    final pdf = pw.Document();
    final fontData =
        await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final font = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            text,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
            ),
          ),
        ],
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
    required this.faceBoxes,
    required this.textBounds,
  });

  final String imagePath;
  final ContentType contentType;
  final List<List<double>> faceBoxes;
  final List<double> textBounds;
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

  final base = img.bakeOrientation(decoded);
  final processed = payload.contentType == ContentType.face
      ? _applyFaceComposite(base, payload.faceBoxes)
      : _applyDocumentCropAndEnhance(base, payload.textBounds);

  final processedBytes = Uint8List.fromList(
    img.encodeJpg(processed, quality: 90),
  );
  return _ProcessResult(processedBytes: processedBytes);
}

img.Image _applyFaceComposite(img.Image base, List<List<double>> boxes) {
  final output = img.Image.from(base);
  if (boxes.isEmpty) {
    return output;
  }

  for (final box in boxes) {
    if (box.length < 4) continue;
    var left = box[0].floor();
    var top = box[1].floor();
    var right = box[2].ceil();
    var bottom = box[3].ceil();

    if (left < 0) left = 0;
    if (top < 0) top = 0;
    if (right > output.width) right = output.width;
    if (bottom > output.height) bottom = output.height;

    final width = right - left;
    final height = bottom - top;
    if (width <= 0 || height <= 0) continue;

    final face = img.copyCrop(output, x: left, y: top, width: width, height: height);
    final grayFace = img.grayscale(face);
    img.compositeImage(output, grayFace, dstX: left, dstY: top);
  }

  return output;
}

img.Image _applyDocumentCropAndEnhance(img.Image base, List<double> bounds) {
  var output = img.Image.from(base);
  if (bounds.length >= 4) {
    var left = bounds[0].floor();
    var top = bounds[1].floor();
    var right = bounds[2].ceil();
    var bottom = bounds[3].ceil();

    if (left < 0) left = 0;
    if (top < 0) top = 0;
    if (right > output.width) right = output.width;
    if (bottom > output.height) bottom = output.height;

    final width = right - left;
    final height = bottom - top;
    if (width > 0 && height > 0) {
      output = img.copyCrop(
        output,
        x: left,
        y: top,
        width: width,
        height: height,
      );
    }
  }

  return img.adjustColor(
    output,
    contrast: 1.1,
    brightness: 1.05,
    saturation: 1.05,
  );
}
