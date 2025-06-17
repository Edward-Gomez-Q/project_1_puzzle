import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TitlePanel extends StatefulWidget {
  final String title;
  final String nameAuthor;
  final String version;
  final double height;
  final double width;
  final Duration duration;

  const TitlePanel({
    super.key,
    required this.title,
    required this.nameAuthor,
    required this.version,
    required this.height,
    required this.width,
    required this.duration,
  });

  @override
  State<TitlePanel> createState() => _TitlePanelState();
}

class _TitlePanelState extends State<TitlePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctx = Get.context!;

    return Container(
      height: widget.height,
      width: widget.width,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.title,
            style: Theme.of(ctx).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "Hecho por ${widget.nameAuthor}",
            style: Theme.of(
              ctx,
            ).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 5),
          Text(
            widget.version,
            style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
              color: Theme.of(ctx).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 16),
          FadeTransition(
            opacity: _opacityAnimation,
            child: Text(
              "Presiona en cualquier parte para ir al menú principal",
              style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                fontSize: 14,
                color: Theme.of(ctx).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
