import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class UnitBanner extends StatelessWidget {
  final int unita;
  final bool compact;

  const UnitBanner({
    super.key,
    required this.unita,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: compact ? 10 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            Icons.precision_manufacturing,
            color: AppColors.neutral,
            size: compact ? 24 : 30,
          ),
          SizedBox(width: compact ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Unità lette',
                  style: TextStyle(
                    color: AppColors.neutral,
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 11 : 13,
                  ),
                ),
                SizedBox(height: compact ? 2 : 3),
                Text(
                  '$unita',
                  style: TextStyle(
                    color: AppColors.neutral,
                    fontWeight: FontWeight.w800,
                    fontSize: compact ? 18 : 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}