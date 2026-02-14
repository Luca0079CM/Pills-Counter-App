import 'package:flutter/material.dart';

class StartBanner extends StatelessWidget {
  final bool ok;
  final String pezzi;

  const StartBanner({
    super.key,
    required this.ok,
    required this.pezzi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
          vertical: 12),
      decoration: BoxDecoration(
        color: ok
            ? const Color(0xFF2E7D32)
            : const Color(0xFFC62828),
        borderRadius:
        BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            ok ? 'OK' : 'KO',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight:
              FontWeight.bold,
            ),
          ),
          Text(
            'Pz: $pezzi',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
