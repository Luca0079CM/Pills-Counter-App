import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CapsuleView extends StatelessWidget {
  final List<String> values;
  final bool showSix;

  const CapsuleView({
    super.key,
    required this.values,
    required this.showSix,
  });

  @override
  Widget build(BuildContext context) {
    final toShow = showSix ? values : values.take(3).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final total = toShow.length;
        final spacing = total >= 6 ? 10.0 : 14.0;
        final availableWidth = constraints.maxWidth;
        final pillWidth =
        ((availableWidth - ((total - 1) * spacing)) / total).clamp(42.0, 70.0);

        Widget pill(String txt) {
          return Container(
            width: pillWidth,
            height: pillWidth * 2.1,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF9F9F9), Color(0xFFE7E7E7)],
              ),
              border: Border.all(color: const Color(0xFFD5D5D5)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x16000000),
                  blurRadius: 14,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              txt.isEmpty ? '-' : txt,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          );
        }

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: spacing,
          runSpacing: 12,
          children: [
            for (final value in toShow) pill(value),
          ],
        );
      },
    );
  }
}