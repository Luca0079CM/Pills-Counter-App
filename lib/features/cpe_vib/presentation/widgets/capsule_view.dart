import 'package:flutter/material.dart';

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

    Widget pill(String txt) {
      return Container(
        width: 43,
        height: 96,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
          ),
          border: Border.all(color: const Color(0xFFBDBDBD)),
          boxShadow: const [
            BoxShadow(
              color: Colors.white70,
              offset: Offset(-2, -2),
              blurRadius: 4,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black26,
              offset: Offset(3, 3),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          txt,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 19),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: toShow.map(pill).toList(),
      ),
    );
  }
}