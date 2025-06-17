import 'package:flutter/material.dart';

class MenuOptionButton extends StatelessWidget {
  final AnimationController controller;
  final IconData icon;
  final String title;
  final String subtitle;
  final int index;
  final VoidCallback onTap;
  final bool isToggle;
  final bool? toggleValue;

  const MenuOptionButton({
    super.key,
    required this.controller,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.index,
    required this.onTap,
    this.isToggle = false,
    this.toggleValue,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final delay = index * 0.1;
        final animationValue =
            (controller.value - delay).clamp(0.0, 1.0) / (1.0 - delay);

        return Transform.translate(
          offset: Offset(50 * (1 - animationValue), 0),
          child: Opacity(
            opacity: animationValue,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).cardColor,
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildIconContainer(context),
                        const SizedBox(width: 16),
                        _buildTextContent(context),
                        _buildArrowIcon(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Theme.of(context).iconTheme.color, size: 24),
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowIcon() {
    if (isToggle && toggleValue != null) {
      return Switch(
        value: toggleValue!,
        onChanged: (_) => onTap(),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }

    return Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]);
  }
}
