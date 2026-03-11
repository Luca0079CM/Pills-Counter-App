import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class NumericInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color? fillColor;

  const NumericInputField({
    super.key,
    required this.label,
    required this.controller,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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