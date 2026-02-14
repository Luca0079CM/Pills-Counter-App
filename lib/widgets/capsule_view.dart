import 'package:flutter/material.dart';

class CapsuleView extends StatelessWidget {
  final List<String> capsules;

  const CapsuleView({
    super.key,
    required this.capsules,
  });

  @override
  Widget build(BuildContext context) {
    Widget pill(String txt) {
      return Container(
        width: 40,
        height: 80,
        margin: const EdgeInsets.symmetric(
            horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(24),
          color: Colors.grey.shade300,
        ),
        child: Text(
          txt,
          style: const TextStyle(
              fontSize: 24,
              fontWeight:
              FontWeight.bold),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection:
      Axis.horizontal,
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children:
        capsules.map(pill).toList(),
      ),
    );
  }
}
