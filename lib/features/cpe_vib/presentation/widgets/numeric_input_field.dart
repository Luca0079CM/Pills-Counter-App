import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class NumericInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color? fillColor;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TapRegionCallback? onTapOutside;

  const NumericInputField({
    super.key,
    required this.label,
    required this.controller,
    this.fillColor,
    this.onChanged,
    this.onSubmitted,
    this.onTapOutside,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTapOutside: onTapOutside,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        fillColor: fillColor ?? const Color(0xFFF4F6F8),
      ),
    );
  }
}