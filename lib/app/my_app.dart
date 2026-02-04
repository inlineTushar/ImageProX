import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/app/bindings/initial_binding.dart';
import '/app/core/values/app_colors.dart';
import '/app/routes/app_pages.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ImageProx',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.pageBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }
}
