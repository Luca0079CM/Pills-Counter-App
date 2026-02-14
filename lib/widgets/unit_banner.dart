import 'package:flutter/material.dart';

class UnitBanner extends StatelessWidget {
  final int unit;

  const UnitBanner({
    super.key,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
          vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF546E7A),
        borderRadius:
        BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            'UN',
            style: TextStyle(
              color: Colors.white,
              fontWeight:
              FontWeight.bold,
            ),
          ),
          Text(
            '$unit',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20),
          ),
        ],
      ),
    );
  }
}
