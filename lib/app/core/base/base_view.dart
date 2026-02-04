import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '/app/core/base/base_controller.dart';
import '/app/core/model/page_state.dart';
import '/app/core/values/app_colors.dart';
import '/app/core/widget/loading.dart';

abstract class BaseView<T extends BaseController> extends GetView<T> {
  const BaseView({super.key});

  Widget buildBody(BuildContext context);

  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  Widget? buildFloatingActionButton(BuildContext context) => null;

  Widget? buildBottomNavigationBar(BuildContext context) => null;

  Color statusBarColor() => AppColors.pageBackground;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: statusBarColor(),
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.pageBackground,
            appBar: buildAppBar(context),
            floatingActionButton: buildFloatingActionButton(context),
            bottomNavigationBar: buildBottomNavigationBar(context),
            body: SafeArea(child: buildBody(context)),
          ),
          Obx(() {
            if (controller.pageState == PageState.loading) {
              return const Loading();
            }
            return const SizedBox.shrink();
          }),
          Obx(() {
            if (controller.errorMessage.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final message = controller.errorMessage;
                if (message.isEmpty) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(message)));
                controller.showError('');
              });
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
