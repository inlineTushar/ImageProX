import 'dart:io';
import 'dart:ui';

import 'package:image/image.dart' as img;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '/app/data/models/content_type.dart';
import '/app/data/services/vision_service.dart';
import '/app/data/services/image_preprocessor.dart';

class ProcessingWorkflowService {
  ProcessingWorkflowService({
    VisionService? visionService,
    ImagePreprocessor? imagePreprocessor,
  })  : _visionService = visionService ?? VisionService(),
        _imagePreprocessor = imagePreprocessor ?? ImagePreprocessor();

  final VisionService _visionService;
  final ImagePreprocessor _imagePreprocessor;

  Future<DetectionResult> detectContent(
    File file, {
    ContentType? forcedType,
    double? scanWidthFactor,
    double? scanHeightFactor,
  }) async {
    if (forcedType == ContentType.face) {
      return _detectFaces(file, scanWidthFactor, scanHeightFactor);
    }

    if (forcedType == ContentType.document) {
      return _detectDocument(file, scanWidthFactor, scanHeightFactor);
    }

    final faceResult =
        await _detectFaces(file, scanWidthFactor, scanHeightFactor);
    if (faceResult.faceBoxes.isNotEmpty) {
      return faceResult;
    }

    final docResult =
        await _detectDocument(file, scanWidthFactor, scanHeightFactor);
    if (_isLikelyDocument(docResult)) {
      return docResult;
    }

    // If text is weak and no faces found, default to face flow to avoid
    // forcing document/PDF output on photos.
    return DetectionResult(
      contentType: ContentType.face,
      faceBoxes: const [],
      textBounds: const [],
      extractedText: null,
    );
  }

  Future<DetectionResult> _detectFaces(
    File file,
    double? scanWidthFactor,
    double? scanHeightFactor,
  ) async {
    final scanRect =
        await _scanWindowForFile(file, scanWidthFactor, scanHeightFactor);
    final faces = await _visionService.detectFaces(file);
    final filteredFaces = scanRect == null
        ? faces
        : faces
            .where((face) => _overlaps(face.boundingBox, scanRect))
            .toList(growable: false);
    final boxes = filteredFaces
        .map((face) => [
              face.boundingBox.left,
              face.boundingBox.top,
              face.boundingBox.right,
              face.boundingBox.bottom,
            ])
        .toList(growable: false);
    return DetectionResult(
      contentType: ContentType.face,
      faceBoxes: boxes,
      textBounds: const [],
      extractedText: null,
    );
  }

  Future<DetectionResult> _detectDocument(
    File file,
    double? scanWidthFactor,
    double? scanHeightFactor,
  ) async {
    final scanRect =
        await _scanWindowForFile(file, scanWidthFactor, scanHeightFactor);
    final text = await _recognizeTextWithFallback(file);
    final bounds = _computeTextBoundsForWindow(text, scanRect);
    final textBounds = bounds == null
        ? const <double>[]
        : [
            bounds.left,
            bounds.top,
            bounds.right,
            bounds.bottom,
          ];
    final extractedText = _extractTextLines(text, scanRect: scanRect);

    return DetectionResult(
      contentType: ContentType.document,
      faceBoxes: const [],
      textBounds: textBounds,
      extractedText: extractedText.isEmpty ? null : extractedText,
    );
  }

  Future<RecognizedText> _recognizeTextWithFallback(File file) async {
    final text = await _visionService.recognizeText(file);
    final extracted = _extractTextLines(text);
    if (extracted.isNotEmpty) {
      return text;
    }
    final enhancedFile = await _imagePreprocessor.enhanceForOcr(file);
    if (enhancedFile == null) {
      return text;
    }
    try {
      return await _visionService.recognizeText(enhancedFile);
    } finally {
      if (await enhancedFile.exists()) {
        await enhancedFile.delete();
      }
    }
  }

  String _extractTextLines(RecognizedText text, {Rect? scanRect}) {
    if (text.blocks.isEmpty) return '';

    final lines = <String>[];
    for (final block in text.blocks) {
      if (scanRect != null && !_overlaps(block.boundingBox, scanRect)) {
        continue;
      }
      if (block.lines.isEmpty) {
        final value = block.text.trim();
        if (value.isNotEmpty) {
          lines.add(value);
        }
        continue;
      }
      for (final line in block.lines) {
        if (scanRect != null && !_overlaps(line.boundingBox, scanRect)) {
          continue;
        }
        final value = line.text.trim();
        if (value.isNotEmpty) {
          lines.add(value);
        }
      }
    }

    if (lines.isEmpty) {
      return text.text.trim();
    }

    return lines.join('\n').trim();
  }

  Future<Rect?> _scanWindowForFile(
    File file,
    double? scanWidthFactor,
    double? scanHeightFactor,
  ) async {
    if (scanWidthFactor == null || scanHeightFactor == null) return null;

    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    final oriented = img.bakeOrientation(decoded);
    final imageSize = Size(
      oriented.width.toDouble(),
      oriented.height.toDouble(),
    );
    final rectWidth = imageSize.width * scanWidthFactor;
    final rectHeight = imageSize.height * scanHeightFactor;
    final left = (imageSize.width - rectWidth) / 2;
    final top = (imageSize.height - rectHeight) / 2;
    return Rect.fromLTWH(left, top, rectWidth, rectHeight);
  }

  Rect? _computeTextBoundsForWindow(RecognizedText text, Rect? scanRect) {
    if (text.blocks.isEmpty) return null;

    double left = double.infinity;
    double top = double.infinity;
    double right = 0;
    double bottom = 0;
    var found = false;

    for (final block in text.blocks) {
      if (scanRect != null && !_overlaps(block.boundingBox, scanRect)) {
        continue;
      }
      final rect = block.boundingBox;
      left = left > rect.left ? rect.left : left;
      top = top > rect.top ? rect.top : top;
      right = right < rect.right ? rect.right : right;
      bottom = bottom < rect.bottom ? rect.bottom : bottom;
      found = true;
    }

    if (!found) return null;
    return Rect.fromLTRB(left, top, right, bottom);
  }

  bool _overlaps(Rect a, Rect b) => a.overlaps(b);

  bool _isLikelyDocument(DetectionResult result) {
    if (result.contentType != ContentType.document) return false;
    if (result.extractedText == null) return false;
    final text = result.extractedText!.trim();
    if (text.isEmpty) return false;

    // Heuristic: require a minimum amount of text to call it a document.
    final lineCount = text.split('\n').where((line) => line.trim().isNotEmpty).length;
    return lineCount >= 3 || text.length >= 80;
  }

  Future<void> dispose() async {
    await _visionService.dispose();
  }
}

class DetectionResult {
  const DetectionResult({
    required this.contentType,
    required this.faceBoxes,
    required this.textBounds,
    required this.extractedText,
  });

  final ContentType contentType;
  final List<List<double>> faceBoxes;
  final List<double> textBounds;
  final String? extractedText;
}
