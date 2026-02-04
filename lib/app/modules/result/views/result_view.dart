import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/app/core/base/base_view.dart';
import '/app/core/values/app_colors.dart';
import '/app/core/values/app_values.dart';
import '/app/modules/result/controllers/result_controller.dart';
import '/app/routes/app_pages.dart';

class ResultView extends BaseView<ResultController> {
  const ResultView({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Result'),
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
          const Text(
            'Before / After',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _ResultCard(label: 'Original'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ResultCard(label: 'Processed'),
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
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppValues.radius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image, size: 56, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
