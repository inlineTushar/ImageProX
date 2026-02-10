import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class VisionService {
  VisionService({
    FaceDetectorOptions? faceDetectorOptions,
  }) : _faceDetector = FaceDetector(
          options: faceDetectorOptions ??
              FaceDetectorOptions(
                enableLandmarks: true,
                enableContours: true,
              ),
        ),
        _textRecognizer = TextRecognizer();

  final FaceDetector _faceDetector;
  final TextRecognizer _textRecognizer;

  Future<List<Face>> detectFaces(File file) async {
    final inputImage = InputImage.fromFile(file);
    return _faceDetector.processImage(inputImage);
  }

  Future<RecognizedText> recognizeText(File file) async {
    final inputImage = InputImage.fromFile(file);
    return _textRecognizer.processImage(inputImage);
  }

  Rect? computeTextBounds(RecognizedText text) {
    if (text.blocks.isEmpty) return null;

    double left = double.infinity;
    double top = double.infinity;
    double right = 0;
    double bottom = 0;

    for (final block in text.blocks) {
      final rect = block.boundingBox;
      left = min(left, rect.left);
      top = min(top, rect.top);
      right = max(right, rect.right);
      bottom = max(bottom, rect.bottom);
    }

    if (left.isInfinite || top.isInfinite) return null;

    return Rect.fromLTRB(left, top, right, bottom);
  }

  Future<void> dispose() async {
    await _faceDetector.close();
    await _textRecognizer.close();
  }
}
