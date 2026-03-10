import 'package:flutter/material.dart';

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
    Widget terminalOption(String label, int n) {
      final selected = activeTerminal == n;

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: 0.95,
            child: Checkbox(
              value: selected,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (_) => onSelected(n),
            ),
          ),
          GestureDetector(
            onTap: () => onSelected(n),
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
        ],
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            const Text('Terminale attivo', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 8),
            terminalOption('T1', 1),
            const SizedBox(width: 8),
            terminalOption('T2', 2),
            const SizedBox(width: 8),
            terminalOption('T3', 3),
          ],
        ),
      ),
    );
  }
}