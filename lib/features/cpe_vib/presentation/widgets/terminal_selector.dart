import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TerminalSelector extends StatelessWidget {
  final int? activeTerminal;
  final ValueChanged<int> onSelected;

  const TerminalSelector({
    super.key,
    required this.activeTerminal,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, int value) {
      final selected = activeTerminal == value;

      return ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(value),
        showCheckmark: false,
        selectedColor: const Color(0xFFDCE7FF),
        backgroundColor: const Color(0xFFF4F6F8),
        side: BorderSide.none,
        labelStyle: TextStyle(
          color: selected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        chip('T1', 1),
        chip('T2', 2),
        chip('T3', 3),
      ],
    );
  }
}