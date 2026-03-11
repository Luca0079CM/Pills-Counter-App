import 'package:flutter/material.dart';
import '../controllers/cpe_vib_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/capsule_view.dart';
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

                if (compact) {
                  return Column(
                    children: [
                      StartResultBanner(
                        ok: state.startResult.ok,
                        pezzi: state.params.pezzi,
                      ),
                      const SizedBox(height: 12),
                      UnitBanner(unita: state.unita),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: StartResultBanner(
                        ok: state.startResult.ok,
                        pezzi: state.params.pezzi,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: UnitBanner(unita: state.unita),
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
                  AppSectionHeader(
                    title: 'Canali capsule',
                    subtitle: state.settings.sixChannelsMode
                        ? 'Visualizzazione 6 canali'
                        : 'Visualizzazione 3 canali',
                    icon: Icons.view_module,
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _ChannelsToggle(
                      isSixChannels: state.settings.sixChannelsMode,
                      onChanged: (_) => controller.toggleSixChannelsMode(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  CapsuleView(
                    values: state.params.capsules,
                    showSix: state.settings.sixChannelsMode,
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
                              label: 'Pezzi',
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
                              label: 'Pezzi',
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
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 430;

                      if (compact) {
                        return Column(
                          children: [
                            AppSecondaryButton(
                              label:
                              state.isConMode ? 'Disattiva Link' : 'Attiva Link',
                              icon: state.isConMode
                                  ? Icons.link_off
                                  : Icons.link,
                              onPressed: controller.toggleConMode,
                              backgroundColor: state.isConMode
                                  ? const Color(0xFFFFF8E1)
                                  : const Color(0xFFE8EEF5),
                              foregroundColor: state.isConMode
                                  ? const Color(0xFF8A6D1F)
                                  : AppColors.neutral,
                            ),
                            const SizedBox(height: 12),
                            AppPrimaryButton(
                              label: state.timer > 0 && state.isAutoLoop
                                  ? 'STOP AUTO-START'
                                  : 'START',
                              icon: state.timer > 0 && state.isAutoLoop
                                  ? Icons.pause_circle
                                  : Icons.play_arrow,
                              onPressed: controller.onStart,
                              height: 58,
                              backgroundColor: AppColors.danger,
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: AppSecondaryButton(
                              label:
                              state.isConMode ? 'Disattiva Link' : 'Attiva Link',
                              icon: state.isConMode
                                  ? Icons.link_off
                                  : Icons.link,
                              onPressed: controller.toggleConMode,
                              backgroundColor: state.isConMode
                                  ? const Color(0xFFFFF8E1)
                                  : const Color(0xFFE8EEF5),
                              foregroundColor: state.isConMode
                                  ? const Color(0xFF8A6D1F)
                                  : AppColors.neutral,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppPrimaryButton(
                              label: state.timer > 0 && state.isAutoLoop
                                  ? 'STOP AUTO-START'
                                  : 'START',
                              icon: state.timer > 0 && state.isAutoLoop
                                  ? Icons.pause_circle
                                  : Icons.play_arrow,
                              onPressed: controller.onStart,
                              height: 54,
                              backgroundColor: AppColors.danger,
                            ),
                          ),
                        ],
                      );
                    },
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

class _ChannelsToggle extends StatelessWidget {
  final bool isSixChannels;
  final ValueChanged<bool> onChanged;

  const _ChannelsToggle({
    required this.isSixChannels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;

    Widget segment({
      required bool selected,
      required String label,
      required IconData icon,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected
                ? const [
              BoxShadow(
                color: Color(0x220D47A1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 12 : 14,
                  vertical: compact ? 11 : 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: compact ? 16 : 18,
                      color:
                      selected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color:
                        selected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                        fontSize: compact ? 12 : 13,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(
        minWidth: compact ? 170 : 190,
        maxWidth: compact ? 210 : 230,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          segment(
            selected: !isSixChannels,
            label: '3 CH',
            icon: Icons.view_week_outlined,
            onTap: () {
              if (isSixChannels) onChanged(false);
            },
          ),
          const SizedBox(width: 4),
          segment(
            selected: isSixChannels,
            label: '6 CH',
            icon: Icons.grid_view_rounded,
            onTap: () {
              if (!isSixChannels) onChanged(true);
            },
          ),
        ],
      ),
    );
  }
}