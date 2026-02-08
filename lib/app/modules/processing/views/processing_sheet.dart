import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/app/core/values/app_colors.dart';
import '/app/core/values/app_values.dart';
import '/app/modules/processing/controllers/processing_controller.dart';
import '/app/core/model/page_state.dart';
import '/l10n/app_localizations.dart';

class ProcessingSheet extends StatelessWidget {
  const ProcessingSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppValues.padding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 140),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => Text(
                  Get.find<ProcessingController>().currentStep,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                )),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: AppColors.primary),
            Obx(() {
              final controller = Get.find<ProcessingController>();
              if (controller.pageState == PageState.error) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      strings.processingFailed,
                      style: const TextStyle(color: AppColors.error),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: controller.retry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(strings.tryAgain),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
