import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'common/app_section_card.dart';
import 'common/app_section_header.dart';

class WifiConfigCard extends StatelessWidget {
  final TextEditingController hostController;
  final TextEditingController portController;
  final ValueChanged<String> onHostChanged;
  final ValueChanged<String> onPortChanged;

  const WifiConfigCard({
    super.key,
    required this.hostController,
    required this.portController,
    required this.onHostChanged,
    required this.onPortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Configurazione Wi-Fi',
            subtitle: 'Inserisci host e porta TCP',
            icon: Icons.wifi,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 420;

              if (compact) {
                return Column(
                  children: [
                    TextField(
                      controller: hostController,
                      onChanged: onHostChanged,
                      decoration: const InputDecoration(
                        labelText: 'Host / IP',
                        hintText: '192.168.1.101 o sxlink-xxxx.local',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: portController,
                      onChanged: onPortChanged,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Porta',
                      ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: hostController,
                      onChanged: onHostChanged,
                      decoration: const InputDecoration(
                        labelText: 'Host / IP',
                        hintText: '192.168.1.101 o sxlink-xxxx.local',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: portController,
                      onChanged: onPortChanged,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Porta',
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'Suggerimento: verifica che telefono e macchina siano sulla stessa rete.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}