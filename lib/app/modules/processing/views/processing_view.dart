import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/app/core/base/base_view.dart';
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
          const Spacer(),
          ElevatedButton(
            onPressed: () => Get.offNamed(Routes.RESULT),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('View Result'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
