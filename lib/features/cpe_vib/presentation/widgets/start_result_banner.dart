import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StartResultBanner extends StatelessWidget {
  final bool ok;
  final int pezzi;

  const StartResultBanner({
    super.key,
    required this.ok,
    required this.pezzi,
  });

  @override
  Widget build(BuildContext context) {
    final bg = ok ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final fg = ok ? AppColors.success : AppColors.danger;
    final icon = ok ? Icons.check_circle : Icons.cancel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ok ? 'Ultimo ciclo OK' : 'Ultimo ciclo KO',
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Pz: $pezzi',
                  style: TextStyle(
                    color: fg,
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