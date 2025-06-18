import 'package:flutter/material.dart';
import 'package:project_1_puzzle/data/models/home/menu_action_type.dart';
import 'package:project_1_puzzle/presentation/getX/theme_controller.dart';
import 'button_menu.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class SlidingMenu extends StatelessWidget {
  final AnimationController controller;
  final Function(MenuAction) onMenuItemTap;

  const SlidingMenu({
    super.key,
    required this.controller,
    required this.onMenuItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final menuAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));

    final scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    return AnimatedBuilder(
      animation: menuAnimation,
      builder: (context, child) {
        return AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          left: 0,
          right: 0,
          bottom: 0,
          child: Transform.translate(
            offset: Offset(
              0,
              MediaQuery.of(context).size.height * menuAnimation.value,
            ),
            child: AnimatedBuilder(
              animation: scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: scaleAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMenuHandle(),
                        _buildMenuTitle(context),
                        ..._buildMenuOptions(context),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildMenuTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Text(
        "Opciones",
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  List<Widget> _buildMenuOptions(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return [
      Obx(() {
        final isDark = themeController.isDarkMode;
        return MenuOptionButton(
          controller: controller,
          icon: isDark ? Icons.light_mode : Icons.dark_mode,
          title: isDark ? 'Tema Claro' : 'Tema Oscuro',
          subtitle: isDark ? 'Cambiar a tema claro' : 'Cambiar a tema oscuro',
          index: 0,
          isToggle: true,
          toggleValue: isDark,
          onTap: () => onMenuItemTap(
            MenuAction.toggle(
              toggleValue: isDark,
              onToggle: () => themeController.toggleTheme(),
            ),
          ),
        );
      }),
      MenuOptionButton(
        controller: controller,
        icon: Icons.arrow_back,
        title: 'Atrás',
        subtitle: 'Volver a la pantalla anterior',
        index: 2,
        onTap: () => onMenuItemTap(
          MenuAction.function(() => GoRouter.of(context).pop()),
        ),
      ),
    ];
  }
}
