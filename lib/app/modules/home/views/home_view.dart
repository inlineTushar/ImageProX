import 'package:flutter/material.dart';
import 'dart:io';

import 'package:get/get.dart';

import '/app/core/base/base_view.dart';
import '/app/core/values/app_colors.dart';
import '/app/core/values/app_values.dart';
import '/app/modules/dialog_select_source/views/dialog_select_source_sheet.dart';
import '/app/modules/home/controllers/home_controller.dart';
import '/app/data/models/content_type.dart';
import '/app/domain/entities/history_entry.dart';
import '/app/domain/entities/processed_result.dart';
import '/app/routes/app_pages.dart';
import '/l10n/app_localizations.dart';

class HomeView extends BaseView<HomeController> {
  const HomeView({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return AppBar(
      title: Text(strings.homeTitle),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    );
  }

  @override
  Widget? buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Get.bottomSheet(
          DialogSelectSourceSheet(
            onCameraTap: controller.onCameraSelected,
            onGalleryTap: controller.onGallerySelected,
          ),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
        );
      },
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add_a_photo),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppValues.padding),
      child: Obx(() {
        final items = controller.items;
        if (items.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.homeEmpty,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            return _HistoryTile(item: item);
          },
        );
      }),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final HistoryEntry item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.type == ContentType.document) {
          Get.toNamed(
            Routes.RESULT_DOCUMENT,
            arguments: ProcessedResult(
              originalPath: item.originalPath,
              processedImagePath: item.processedPath,
              contentType: ContentType.document,
              title: item.title,
              pdfPath: item.pdfPath,
              extractedText: item.extractedText,
            ),
          );
        } else {
          Get.toNamed(
            Routes.RESULT_FACE,
            arguments: ProcessedResult(
              originalPath: item.originalPath,
              processedImagePath: item.processedPath,
              contentType: ContentType.face,
              title: item.title,
              extractedText: item.extractedText,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppValues.padding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppValues.radius),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            _HistoryThumbnail(item: item),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(item.createdAt),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final date = value.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[date.month - 1];
    return '$month ${date.day}, ${date.year}';
  }
}

class _HistoryThumbnail extends StatelessWidget {
  const _HistoryThumbnail({required this.item});

  final HistoryEntry item;

  @override
  Widget build(BuildContext context) {
    final path = item.thumbnailPath ?? item.processedPath;
    final hasImage = path.isNotEmpty && File(path).existsSync();

    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppValues.radiusSmall),
        border: Border.all(color: AppColors.divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppValues.radiusSmall),
        child: hasImage
            ? Image.file(
                File(path),
                fit: BoxFit.cover,
              )
            : Icon(
                item.type == ContentType.face
                    ? Icons.face
                    : Icons.picture_as_pdf,
                color: AppColors.textSecondary,
              ),
      ),
    );
  }
}
