import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/app/core/values/app_colors.dart';
import '/app/core/values/app_values.dart';
import '/app/modules/processing/controllers/processing_controller.dart';
import '/app/core/model/page_state.dart';
import '/app/data/models/content_type.dart';
import '/app/routes/app_pages.dart';
import '/l10n/app_localizations.dart';

class ProcessingSheet extends StatefulWidget {
  const ProcessingSheet({super.key});

  @override
  State<ProcessingSheet> createState() => _ProcessingSheetState();
}

class _ProcessingSheetState extends State<ProcessingSheet> {
  bool _didNavigate = false;
  late final ProcessingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProcessingController>();
  }

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
            Obx(() {
              return Text(
                _controller.currentStep,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              );
            }),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: AppColors.primary),
            Obx(() {
              final result = _controller.result;
              if (result != null && !_didNavigate) {
                _didNavigate = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (Get.isBottomSheetOpen ?? false) {
                    Get.back();
                  }
                  if (result.contentType == ContentType.document) {
                    Get.offNamed(
                      Routes.RESULT_DOCUMENT,
                      arguments: result,
                    );
                  } else {
                    Get.offNamed(
                      Routes.RESULT_FACE,
                      arguments: result,
                    );
                  }
                });
              }

              if (_controller.pageState == PageState.error) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      strings.processingFailed,
                      style: const TextStyle(color: AppColors.error),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _controller.retry,
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
