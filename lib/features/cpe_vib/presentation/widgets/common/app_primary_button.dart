import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool expanded;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 54,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      height: height,
      width: expanded ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: foregroundColor ?? Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
      ),
    );

    if (icon == null) {
      return SizedBox(
        height: height,
        width: expanded ? double.infinity : null,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primary,
            foregroundColor: foregroundColor ?? Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18),
          ),
          child: Text(label),
        ),
      );
    }

    return button;
  }
}