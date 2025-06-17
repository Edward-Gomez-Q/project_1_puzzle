import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_1_puzzle/config/routes/app_router.dart';
import 'package:project_1_puzzle/core/theme/app_theme.dart';
import 'package:project_1_puzzle/presentation/getX/theme_controller.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  final ThemeController themeController = Get.put(ThemeController());
  MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => MaterialApp.router(
        title: 'Project 1 Puzzle',
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        themeMode: themeController.themeMode.value,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
