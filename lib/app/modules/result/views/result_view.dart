import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/app/core/base/base_view.dart';
import '/app/core/values/app_colors.dart';
import '/app/core/values/app_values.dart';
import '/app/routes/app_pages.dart';
import '/app/modules/processing/controllers/processing_controller.dart';
import '/app/modules/result/controllers/result_controller.dart';
import '/l10n/app_localizations.dart';

class ResultView extends BaseView<ResultController> {
  const ResultView({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return AppBar(
      title: Text(strings.resultTitle),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final result = controller.result;
    return Padding(
      padding: const EdgeInsets.all(AppValues.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (result != null) const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _ResultCard(
                    label: AppLocalizations.of(context)!.original,
                    badgeText: 'Before',
                    imagePath: result?.originalPath,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ResultCard(
                    label: AppLocalizations.of(context)!.processed,
                    badgeText: 'After',
                    imagePath: result?.processedImagePath,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.offAllNamed(Routes.HOME),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(AppLocalizations.of(context)!.done),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.label,
    required this.badgeText,
    this.imagePath,
  });

  final String label;
  final String badgeText;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    final hasImage = path != null && path.isNotEmpty && File(path).existsSync();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppValues.radius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: hasImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppValues.radius),
                          child: Image.file(
                            File(path!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.image,
                            size: 56,
                            color: AppColors.textSecondary,
                          ),
                        ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
