import 'package:flutter/material.dart';
import 'pages/home_page.dart';

class CpeVibApp extends StatelessWidget {
  const CpeVibApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CPE-VIB Serial-BT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
        ),
      ),
      home: const HomePage(),
    );
  }
}
