import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/app/core/base/base_view.dart';
import '/app/core/values/app_colors.dart';
import '/app/modules/camera_scan/controllers/camera_scan_controller.dart';

class CameraScanView extends BaseView<CameraScanController> {
  const CameraScanView({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Scan'),
      backgroundColor: AppColors.surface,
      foregroundColor: Colors.white,
      actions: [
        Obx(() {
          final _ = controller.cameraIndex;
          final ready = controller.isReady;
          return IconButton(
            onPressed: ready && controller.canSwitch
                ? controller.switchCamera
                : null,
            icon: const Icon(Icons.cameraswitch),
          );
        }),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Obx(() {
      if (!controller.isReady || controller.controller == null) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      return Stack(
        children: [
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.controller!.value.previewSize?.height ?? 0,
                height: controller.controller!.value.previewSize?.width ?? 0,
                child: CameraPreview(controller.controller!),
              ),
            ),
          ),
          Positioned.fill(
            child: _ScanOverlay(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: FloatingActionButton(
                onPressed: () async {
                  final path = await controller.takePicture();
                  if (path == null || path.isEmpty) return;
                  Get.back(result: {'path': path});
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.camera_alt),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScanOverlayPainter(),
      size: Size.infinite,
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rectWidth = size.width * 0.75;
    final rectHeight = size.height * 0.45;
    final left = (size.width - rectWidth) / 2;
    final top = (size.height - rectHeight) / 2;
    final rect = Rect.fromLTWH(left, top, rectWidth, rectHeight);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    final overlayPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()..addRRect(rrect);
    final dimPath = Path.combine(PathOperation.difference, overlayPath, holePath);

    final dimPaint = Paint()..color = Colors.black.withOpacity(0.35);
    canvas.drawPath(dimPath, dimPaint);

    final borderPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
