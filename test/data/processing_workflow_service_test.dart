import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'package:imageprox/app/data/models/content_type.dart';
import 'package:imageprox/app/data/services/image_preprocessor.dart';
import 'package:imageprox/app/data/services/processing_workflow_service.dart';
import 'package:imageprox/app/data/services/vision_service.dart';

class _MockVisionService extends Mock implements VisionService {}
class _MockImagePreprocessor extends Mock implements ImagePreprocessor {}

void main() {
  setUpAll(() {
    registerFallbackValue(File('test.jpg'));
    registerFallbackValue(
      RecognizedText(
        text: '',
        blocks: const [],
      ),
    );
  });

  group('ProcessingWorkflowService', () {
    late VisionService vision;
    late ImagePreprocessor preprocessor;
    late ProcessingWorkflowService service;

    setUp(() {
      vision = _MockVisionService();
      preprocessor = _MockImagePreprocessor();
      service = ProcessingWorkflowService(
        visionService: vision,
        imagePreprocessor: preprocessor,
      );
    });

    test('detects face first when faces exist', () async {
      when(() => vision.detectFaces(any())).thenAnswer(
        (_) async => [
          Face(
            boundingBox: const Rect.fromLTWH(0, 0, 10, 10),
            landmarks: const {},
            contours: const {},
            trackingId: null,
            headEulerAngleX: null,
            headEulerAngleY: null,
            headEulerAngleZ: null,
            leftEyeOpenProbability: null,
            rightEyeOpenProbability: null,
            smilingProbability: null,
          ),
        ],
      );
      when(() => vision.recognizeText(any())).thenAnswer(
        (_) async => RecognizedText(text: '', blocks: const []),
      );

      final result = await service.detectContent(
        File('dummy.jpg'),
      );

      expect(result.contentType, ContentType.face);
      expect(result.faceBoxes, isNotEmpty);
    });

    test('detects document when no faces found', () async {
      when(() => vision.detectFaces(any())).thenAnswer((_) async => []);
      when(() => vision.recognizeText(any())).thenAnswer(
        (_) async => RecognizedText(
          text: 'Hello',
          blocks: [
            TextBlock(
              text: 'Hello',
              boundingBox: const Rect.fromLTWH(0, 0, 10, 10),
              recognizedLanguages: const [],
              lines: const [],
              cornerPoints: const [],
            ),
          ],
        ),
      );

      final result = await service.detectContent(
        File('dummy.jpg'),
      );

      expect(result.contentType, ContentType.document);
    });
  });
}
