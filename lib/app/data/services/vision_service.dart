import 'dart:io';

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

  Future<void> dispose() async {
    await _faceDetector.close();
    await _textRecognizer.close();
  }
}
