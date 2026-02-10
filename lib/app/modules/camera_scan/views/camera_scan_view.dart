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
            child: _ScanOverlay(
              widthFactor: controller.scanWidthFactor,
              heightFactor: controller.scanHeightFactor,
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: _ScanControls(controller: controller),
          ),
        ],
      );
    });
  }
}

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay({
    required this.widthFactor,
    required this.heightFactor,
  });

  final double widthFactor;
  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScanOverlayPainter(
        widthFactor: widthFactor,
        heightFactor: heightFactor,
      ),
      size: Size.infinite,
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  _ScanOverlayPainter({
    required this.widthFactor,
    required this.heightFactor,
  });

  final double widthFactor;
  final double heightFactor;

  @override
  void paint(Canvas canvas, Size size) {
    final rectWidth = size.width * widthFactor;
    final rectHeight = size.height * heightFactor;
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
  bool shouldRepaint(covariant _ScanOverlayPainter oldDelegate) {
    return oldDelegate.widthFactor != widthFactor ||
        oldDelegate.heightFactor != heightFactor;
  }
}

class _ScanControls extends StatelessWidget {
  const _ScanControls({required this.controller});

  final CameraScanController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LabeledSlider(
            label: 'Width',
            value: controller.scanWidthFactor,
            min: 0.6,
            max: 1.0,
            onChanged: controller.updateScanWidth,
          ),
          const SizedBox(height: 8),
          _LabeledSlider(
            label: 'Height',
            value: controller.scanHeightFactor,
            min: 0.4,
            max: 0.9,
            onChanged: controller.updateScanHeight,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final path = await controller.takePicture();
                if (path == null || path.isEmpty) return;
                Get.back(
                  result: {
                    'path': path,
                    'scanWidthFactor': controller.scanWidthFactor,
                    'scanHeightFactor': controller.scanHeightFactor,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.check),
              label: const Text('Confirm Window'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            value.toStringAsFixed(2),
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
