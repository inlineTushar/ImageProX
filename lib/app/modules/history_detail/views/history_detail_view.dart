import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/app/core/base/base_view.dart';
import '/app/core/values/app_colors.dart';
import '/app/core/values/app_values.dart';
import '/app/modules/history_detail/controllers/history_detail_controller.dart';
import '/app/modules/home/models/history_item.dart';

class HistoryDetailView extends BaseView<HistoryDetailController> {
  const HistoryDetailView({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('History Detail'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final item = controller.item;

    return Padding(
      padding: const EdgeInsets.all(AppValues.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppValues.radius),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 72, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item?.label ?? 'Processed Item',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item == null ? '' : _formatDate(item.createdAt),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (item != null && item.type == HistoryType.document)
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Open PDF'),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final date = value.toLocal();
    return '${date.month}/${date.day}/${date.year}';
  }
}
