import 'package:flutter/material.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ok ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            ok ? 'OK' : 'KO',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Pz: $pezzi',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}