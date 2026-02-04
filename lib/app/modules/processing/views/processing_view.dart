import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/app/core/base/base_view.dart';
import '/app/core/model/page_state.dart';
import '/app/core/values/app_colors.dart';
import '/app/core/values/app_values.dart';
import '/app/modules/processing/controllers/processing_controller.dart';
import '/app/routes/app_pages.dart';

class ProcessingView extends BaseView<ProcessingController> {
  const ProcessingView({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Processing'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppValues.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppValues.radius),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 64, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          Obx(() => Text(
                controller.currentStep,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              )),
          const SizedBox(height: 16),
          const LinearProgressIndicator(color: AppColors.primary),
          Obx(() {
            if (controller.pageState == PageState.error) {
              return Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Processing failed.',
                    style: TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Get.offNamed(Routes.CAPTURE),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          const Spacer(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
