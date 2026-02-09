import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '/app/core/base/base_controller.dart';

class CameraScanController extends BaseController {
  final RxBool _isReady = false.obs;
  final RxInt _cameraIndex = 0.obs;

  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  late final FaceDetector _faceDetector;
  late final TextRecognizer _textRecognizer;
  bool _isProcessing = false;
  bool _isCapturing = false;
  int _frameCount = 0;
  static const double _scanWidthFactor = 0.75;
  static const double _scanHeightFactor = 0.45;

  bool get isReady => _isReady.value;
  CameraController? get controller => _controller;
  int get cameraIndex => _cameraIndex.value;
  bool get canSwitch => _cameras.length > 1;

  @override
  void onInit() {
    super.onInit();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: false,
        enableContours: false,
      ),
    );
    _textRecognizer = TextRecognizer();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        showError('No camera available');
        return;
      }
      await _startCamera(_cameras[_cameraIndex.value]);
      _isReady(true);
      _startStream();
    } catch (e) {
      showError(e.toString());
    }
  }

  Future<void> _startCamera(CameraDescription description) async {
    await _controller?.dispose();
    _controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    await _controller!.initialize();
  }

  Future<void> switchCamera() async {
    if (!canSwitch) return;
    _cameraIndex((_cameraIndex.value + 1) % _cameras.length);
    await _startCamera(_cameras[_cameraIndex.value]);
    _isReady(true);
    _frameCount = 0;
    _isProcessing = false;
    _startStream();
  }

  Future<String?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return null;
    final file = await _controller!.takePicture();
    return file.path;
  }

  void _startStream() {
    final controller = _controller;
    if (controller == null) return;

    controller.startImageStream((CameraImage image) async {
      if (_isProcessing || _isCapturing) return;
      _frameCount++;
      if (_frameCount % 8 != 0) return;

      _isProcessing = true;
      try {
        final inputImage = _inputImageFromCameraImage(image, controller);
        if (inputImage == null) return;

        final imageSize = inputImage.metadata?.size;
        final scanWindow = imageSize == null ? null : _scanWindow(imageSize);

        final faces = await _faceDetector.processImage(inputImage);
        if (faces.isNotEmpty &&
            (scanWindow == null ||
                faces.any((face) => _isInScanWindow(face.boundingBox, scanWindow)))) {
          await _finalizeCapture('face');
          return;
        }

        final text = await _textRecognizer.processImage(inputImage);
        if (text.blocks.isNotEmpty &&
            (scanWindow == null ||
                text.blocks
                    .any((block) => _isInScanWindow(block.boundingBox, scanWindow)))) {
          await _finalizeCapture('document');
          return;
        }
      } catch (_) {
        // swallow frame errors
      } finally {
        _isProcessing = false;
      }
    });
  }

  Future<void> _finalizeCapture(String type) async {
    if (_isCapturing) return;
    _isCapturing = true;
    final controller = _controller;
    if (controller == null) return;

    await controller.stopImageStream();
    final file = await controller.takePicture();
    Get.back(result: {
      'path': file.path,
      'type': type,
    });
  }

  InputImage? _inputImageFromCameraImage(
    CameraImage image,
    CameraController controller,
  ) {
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final rotation = _rotationFromSensor(
      controller.description.sensorOrientation,
      controller.description.lensDirection,
      controller.value.deviceOrientation,
    );
    if (rotation == null) return null;

    if (image.planes.isEmpty) return null;
    final bytes = image.planes.first.bytes;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  InputImageRotation? _rotationFromSensor(
    int sensorOrientation,
    CameraLensDirection lensDirection,
    DeviceOrientation deviceOrientation,
  ) {
    final rotationCompensation = _deviceRotation(deviceOrientation);
    if (rotationCompensation == null) return null;

    int rotation;
    if (lensDirection == CameraLensDirection.front) {
      rotation = (sensorOrientation + rotationCompensation) % 360;
    } else {
      rotation = (sensorOrientation - rotationCompensation + 360) % 360;
    }

    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      case 0:
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  int? _deviceRotation(DeviceOrientation orientation) {
    switch (orientation) {
      case DeviceOrientation.portraitUp:
        return 0;
      case DeviceOrientation.landscapeLeft:
        return 90;
      case DeviceOrientation.portraitDown:
        return 180;
      case DeviceOrientation.landscapeRight:
        return 270;
    }
  }

  Rect _scanWindow(Size imageSize) {
    final rectWidth = imageSize.width * _scanWidthFactor;
    final rectHeight = imageSize.height * _scanHeightFactor;
    final left = (imageSize.width - rectWidth) / 2;
    final top = (imageSize.height - rectHeight) / 2;
    return Rect.fromLTWH(left, top, rectWidth, rectHeight);
  }

  bool _isInScanWindow(Rect box, Rect window) {
    return window.overlaps(box);
  }

  @override
  void onClose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    _faceDetector.close();
    _textRecognizer.close();
    super.onClose();
  }
}
