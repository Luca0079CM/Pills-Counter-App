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
    final toShow = showSix ? values.take(6).toList() : values.take(3).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Dimensioni più compatte e stabili, così 6 canali stanno dentro
        // e 3 canali restano centrati senza sembrare enormi.
        double pillWidth;
        double spacing;
        double fontSize;

        if (width < 360) {
          pillWidth = 40;
          spacing = 8;
          fontSize = 22;
        } else if (width < 390) {
          pillWidth = 43;
          spacing = 9;
          fontSize = 23;
        } else if (width < 430) {
          pillWidth = 46;
          spacing = 10;
          fontSize = 24;
        } else {
          pillWidth = 50;
          spacing = 12;
          fontSize = 25;
        }

        Widget pill(String txt) {
          return Container(
            width: pillWidth,
            height: pillWidth * 1.95,
            alignment: Alignment.center,
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
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              txt.isEmpty ? '-' : txt,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          );
        }

        return Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: spacing,
            runSpacing: 10,
            children: [
              for (final value in toShow) pill(value),
            ],
          ),
        );
      },
    );
  }
}