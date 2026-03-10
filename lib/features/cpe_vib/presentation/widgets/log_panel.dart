import 'package:flutter/material.dart';

class LogPanel extends StatelessWidget {
  final List<String> logs;

  const LogPanel({
    super.key,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 120, maxHeight: 120),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFBDBDBD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: logs.isEmpty
          ? const Text('Log vuoto...', style: TextStyle(color: Colors.black54))
          : ListView.builder(
        reverse: true,
        itemCount: logs.length,
        itemBuilder: (_, i) => Text(logs[i]),
      ),
    );
  }
}