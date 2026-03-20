import 'package:flutter/material.dart';
import '../controllers/cpe_vib_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_page_padding.dart';
import '../widgets/common/app_primary_button.dart';
import '../widgets/common/app_section_card.dart';
import '../widgets/common/app_section_header.dart';
import '../widgets/common/app_status_chip.dart';
import '../widgets/common/app_secondary_button.dart';
import '../widgets/terminal_selector.dart';
import '../widgets/wifi_config_card.dart';

class ConnectionPage extends StatelessWidget {
  final CpeVibController controller;
  final TextEditingController hostController;
  final TextEditingController portController;

  const ConnectionPage({
    super.key,
    required this.controller,
    required this.hostController,
    required this.portController,
  });

  Widget _buildLinkActionButton({
    required bool isConMode,
    required VoidCallback onPressed,
  }) {
    return AppSecondaryButton(
      label: isConMode ? 'Disattiva link' : 'Attiva link',
      icon: isConMode ? Icons.link_off : Icons.link,
      onPressed: onPressed,
      backgroundColor:
          isConMode ? const Color(0xFFFFF8E1) : const Color(0xFFEAF1F6),
      foregroundColor:
          isConMode ? const Color(0xFF8A6D1F) : AppColors.textSecondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = controller.state;

    return SingleChildScrollView(
      child: AppPagePadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSectionCard(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Image.asset(
                      'assets/images/CPEV_t.BMP',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text(
                          'Logo non disponibile',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppStatusChip(
                    label: state.isConnected
                        ? 'Connesso${state.activeTerminal != null ? ' • T${state.activeTerminal}' : ''}'
                        : 'Disconnesso',
                    backgroundColor: state.isConnected
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFF1F5F9),
                    foregroundColor:
                    state.isConnected ? AppColors.success : AppColors.neutral,
                    icon: state.isConnected ? Icons.check_circle : Icons.link_off,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            if (state.settings.expMode)
              WifiConfigCard(
                hostController: hostController,
                portController: portController,
                onHostChanged: controller.setHost,
                onPortChanged: controller.setPort,
              ),
            if (state.settings.expMode)
              const SizedBox(height: AppSpacing.section),
            if (state.settings.expMode)
              AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionHeader(
                      title: 'Terminale attivo',
                      subtitle: "La macchina usa sempre l'IP fisso 192.168.1.101",
                      icon: Icons.router,
                    ),
                    const SizedBox(height: 16),
                    TerminalSelector(
                      activeTerminal: 1,
                      enabledTerminals: const {1},
                      onSelected: controller.setActiveTerminal,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.section),
            AppPrimaryButton(
              label: state.isConnected
                  ? 'Disconnetti macchina'
                  : 'Connetti macchina',
              onPressed: state.isConnected
                  ? controller.disconnect
                  : controller.connect,
              icon: state.isConnected ? Icons.link_off : Icons.wifi,
              height: 58,
              backgroundColor:
              state.isConnected ? AppColors.success : AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.section),
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionHeader(
                    title: 'Comandi macchina',
                    subtitle: 'Gestione collegamento e avvio conteggio',
                    icon: Icons.play_circle_outline,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      AppStatusChip(
                        label: state.isConMode ? 'LINK-ON' : 'LINK-OFF',
                        backgroundColor: state.isConMode
                            ? const Color(0xFFFFF8E1)
                            : const Color(0xFFEAF1F6),
                        foregroundColor: state.isConMode
                            ? const Color(0xFF8A6D1F)
                            : AppColors.neutral,
                        icon: state.isConMode ? Icons.link : Icons.link_off,
                      ),
                      SizedBox(
                        width: 190,
                        child: _buildLinkActionButton(
                          isConMode: state.isConMode,
                          onPressed: controller.toggleConMode,
                        ),
                      ),
                      if (state.timer != 0)
                        AppStatusChip(
                          label: state.isAutoLoop
                              ? 'AUTO-START attivo (${state.timer}s)'
                              : 'AUTO-START ${state.timer}s',
                          backgroundColor: const Color(0xFFFFEBEE),
                          foregroundColor: AppColors.danger,
                          icon: Icons.timer,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}