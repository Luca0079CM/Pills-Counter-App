import 'package:flutter/material.dart';

class TerminalSelector extends StatelessWidget {
  final int active;
  final ValueChanged<int> onChanged;

  const TerminalSelector({
    super.key,
    required this.active,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget item(String label, int n) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: active == n,
            onChanged: (_) =>
                onChanged(n),
          ),
          GestureDetector(
            onTap: () =>
                onChanged(n),
            child: Text(label),
          ),
        ],
      );
    }

    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(8),
        child: Row(
          children: [
            const Text(
                'Terminale attivo'),
            const SizedBox(width: 8),
            item('T1', 1),
            item('T2', 2),
            item('T3', 3),
          ],
        ),
      ),
    );
  }
}
