import 'package:flutter/material.dart';
import '../controllers/cpe_vib_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/numeric_input_field.dart';
import '../widgets/start_result_banner.dart';
import '../widgets/unit_banner.dart';
import '../widgets/common/app_page_padding.dart';
import '../widgets/common/app_primary_button.dart';
import '../widgets/common/app_secondary_button.dart';
import '../widgets/common/app_section_card.dart';
import '../widgets/common/app_section_header.dart';
import '../widgets/common/app_status_chip.dart';

class HomePage extends StatelessWidget {
  final CpeVibController controller;
  final TextEditingController pezziController;

  const HomePage({
    super.key,
    required this.controller,
    required this.pezziController,
  });


  Widget _buildLinkActionButton({
    required bool isConnected,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(isConnected ? Icons.link_off : Icons.link, size: 17),
      label: Text(isConnected ? 'Disattiva link' : 'Attiva link'),
      style: OutlinedButton.styleFrom(
        foregroundColor:
            isConnected ? const Color(0xFF8A6D1F) : AppColors.textSecondary,
        backgroundColor:
            isConnected ? const Color(0xFFFFF8E1) : const Color(0xFFEAF1F6),
        side: BorderSide(
          color: isConnected ? const Color(0xFFF3D9A4) : AppColors.border,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
      ),
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
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 430;
                final ultraCompact = constraints.maxWidth < 340;

                if (ultraCompact) {
                  return Column(
                    children: [
                      StartResultBanner(
                        ok: state.startResult.ok,
                        pezzi: state.params.pezzi,
                        compact: true,
                      ),
                      const SizedBox(height: 10),
                      UnitBanner(
                        unita: state.unita,
                        compact: true,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: StartResultBanner(
                        ok: state.startResult.ok,
                        pezzi: state.params.pezzi,
                        compact: compact,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: UnitBanner(
                        unita: state.unita,
                        compact: compact,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.section),
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionHeader(
                    title: 'Impostazione rapida',
                    subtitle: 'Configura il numero pezzi da conteggiare',
                    icon: Icons.tune,
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 430;

                      if (compact) {
                        return Column(
                          children: [
                            NumericInputField(
                              label: 'Pezzi (1-999)',
                              controller: pezziController,
                            ),
                            const SizedBox(height: 12),
                            AppSecondaryButton(
                              label: 'Imposta',
                              icon: Icons.check,
                              onPressed: controller.onImpostaPressed,
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: NumericInputField(
                              label: 'Pezzi (1-999)',
                              controller: pezziController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppSecondaryButton(
                              label: 'Imposta',
                              icon: Icons.check,
                              onPressed: controller.onImpostaPressed,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
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
                      _buildLinkActionButton(
                        isConnected: state.isConMode,
                        onPressed: controller.toggleConMode,
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
                  const SizedBox(height: 12),
                  AppPrimaryButton(
                    label: state.timer > 0 && state.isAutoLoop
                        ? 'STOP AUTO-START'
                        : 'START CONTEGGIO',
                    icon: state.timer > 0 && state.isAutoLoop
                        ? Icons.pause_circle
                        : Icons.play_arrow_rounded,
                    onPressed: controller.onStart,
                    height: 66,
                    backgroundColor: AppColors.danger,
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
