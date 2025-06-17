import 'package:flutter/material.dart';

enum MenuActionType { route, function, toggle }

class MenuAction {
  final MenuActionType type;
  final String? route;
  final VoidCallback? function;
  final bool? toggleValue;
  final VoidCallback? onToggle;

  MenuAction.route(this.route)
    : type = MenuActionType.route,
      function = null,
      toggleValue = null,
      onToggle = null;

  MenuAction.function(this.function)
    : type = MenuActionType.function,
      route = null,
      toggleValue = null,
      onToggle = null;

  MenuAction.toggle({required this.toggleValue, required this.onToggle})
    : type = MenuActionType.toggle,
      route = null,
      function = null;
}
