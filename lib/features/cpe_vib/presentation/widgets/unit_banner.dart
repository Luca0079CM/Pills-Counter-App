import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class UnitBanner extends StatelessWidget {
  final int unita;

  const UnitBanner({
    super.key,
    required this.unita,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.precision_manufacturing,
            color: AppColors.neutral,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Unità lette',
                  style: TextStyle(
                    color: AppColors.neutral,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$unita',
                  style: const TextStyle(
                    color: AppColors.neutral,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
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