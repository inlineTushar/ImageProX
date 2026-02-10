import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '/app/data/models/content_type.dart';
import '/app/domain/services/image_processing_service.dart';

class ImageProcessingServiceImpl implements ImageProcessingService {
  @override
  Future<Uint8List> process(
    String imagePath, {
    required ContentType contentType,
    List<List<double>>? faceBoxes,
    List<double>? textBounds,
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
    return result.processedBytes;
  }
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

    final face = img.copyCrop(
      output,
      x: left,
      y: top,
      width: width,
      height: height,
    );
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
