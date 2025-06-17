import 'package:flutter/material.dart';

class AnimatedOverlay extends StatelessWidget {
  final AnimationController controller;
  final VoidCallback onTap;

  const AnimatedOverlay({
    super.key,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final overlayAnimation = Tween<double>(
      begin: 0.0,
      end: 0.7,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    return AnimatedBuilder(
      animation: overlayAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            color: Colors.black.withValues(alpha: overlayAnimation.value),
          ),
        );
      },
    );
  }
}
