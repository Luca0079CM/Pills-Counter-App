import 'package:flutter/material.dart';
import '../features/cpe_vib/presentation/pages/cpe_vib_shell_page.dart';
import 'app_theme.dart';

class CpeVibApp extends StatelessWidget {
  const CpeVibApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CPE-VIB Serial-BT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const CpeVibShellPage(),
    );
  }
}