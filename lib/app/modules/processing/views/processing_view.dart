import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/app/core/base/base_view.dart';
import '/app/core/model/page_state.dart';
import '/app/core/values/app_colors.dart';
import '/app/core/values/app_values.dart';
import '/app/modules/processing/controllers/processing_controller.dart';
import '/app/routes/app_pages.dart';
import '/l10n/app_localizations.dart';

class ProcessingView extends BaseView<ProcessingController> {
  const ProcessingView({super.key});

  @override
  bool showGlobalLoader() => false;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return AppBar(
      title: Text(strings.processingTitle),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppValues.padding),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(() => Text(
                  controller.currentStep,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                )),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppColors.primary),
            Obx(() {
              if (controller.pageState == PageState.error) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.processingFailed,
                    style: const TextStyle(color: AppColors.error),
                  ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => Get.offNamed(Routes.CAPTURE),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    child: Text(AppLocalizations.of(context)!.tryAgain),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
