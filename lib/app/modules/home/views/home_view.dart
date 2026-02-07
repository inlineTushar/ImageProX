import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/app/core/base/base_view.dart';
import '/app/core/values/app_colors.dart';
import '/app/core/values/app_values.dart';
import '/app/modules/home/controllers/home_controller.dart';
import '/app/modules/home/models/history_item.dart';
import '/app/modules/processing/controllers/processing_controller.dart';
import '/app/modules/processing/models/processing_result.dart';
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
      onPressed: () => Get.toNamed(Routes.CAPTURE),
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

  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.type == HistoryType.document) {
          Get.toNamed(
            Routes.PDF_CREATED,
            arguments: ProcessingResult(
              originalPath: item.originalPath,
              processedImagePath: item.processedPath,
              contentType: ContentType.document,
              title: item.title,
              pdfPath: item.pdfPath,
            ),
          );
        } else {
          Get.toNamed(
            Routes.RESULT,
            arguments: ProcessingResult(
              originalPath: item.originalPath,
              processedImagePath: item.processedPath,
              contentType: ContentType.face,
              title: item.title,
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
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: item.type == HistoryType.face
                    ? AppColors.accent
                    : AppColors.primaryDark,
                borderRadius: BorderRadius.circular(AppValues.radiusSmall),
              ),
                child: Icon(
                item.type == HistoryType.face ? Icons.face : Icons.picture_as_pdf,
                color: Colors.white,
              ),
            ),
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
    return '${date.month}/${date.day}/${date.year}';
  }
}
