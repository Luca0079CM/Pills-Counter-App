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
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 150,
        maxHeight: 220,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: logs.isEmpty
          ? const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Log vuoto...',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      )
          : Scrollbar(
        thumbVisibility: true,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          reverse: true,
          itemCount: logs.length,
          separatorBuilder: (_, __) =>
          const Divider(color: Colors.white12, height: 12),
          itemBuilder: (_, i) => Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              child: Text(
                logs[i],
                softWrap: true,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  color: Color(0xFFE5E7EB),
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}