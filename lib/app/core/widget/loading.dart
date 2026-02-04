import 'package:flutter/material.dart';

import '/app/core/values/app_colors.dart';
import '/app/core/values/app_values.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.1),
      child: const Center(
        child: SizedBox(
          height: AppValues.loadingSize,
          width: AppValues.loadingSize,
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
