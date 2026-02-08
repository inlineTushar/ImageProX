import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/app/core/base/base_view.dart';
import '/app/core/values/app_colors.dart';
import '/app/core/values/app_values.dart';
import '/app/modules/dialog_select_source/controllers/capture_controller.dart';
import '/app/routes/app_pages.dart';
import '/l10n/app_localizations.dart';

class CaptureView extends BaseView<CaptureController> {
  const CaptureView({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return AppBar(
      title: Text(strings.captureTitle),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppValues.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.captureSourceLabel,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _SourceButton(
            icon: Icons.photo_camera,
            label: AppLocalizations.of(context)!.camera,
            onTap: controller.selectCamera,
          ),
          const SizedBox(height: 12),
          _SourceButton(
            icon: Icons.photo_library,
            label: AppLocalizations.of(context)!.gallery,
            onTap: controller.selectGallery,
          ),
        ],
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppValues.radiusSmall),
        ),
      ),
    );
  }
}
