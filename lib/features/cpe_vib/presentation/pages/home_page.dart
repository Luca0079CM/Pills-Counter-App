import 'package:flutter/material.dart';
import '../controllers/cpe_vib_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/numeric_input_field.dart';
import '../widgets/start_result_banner.dart';
import '../widgets/unit_banner.dart';
import '../widgets/channels_capsule_card.dart';
import '../widgets/common/app_page_padding.dart';
import '../widgets/common/app_primary_button.dart';
import '../widgets/common/app_secondary_button.dart';
import '../widgets/common/app_section_card.dart';
import '../widgets/common/app_section_header.dart';

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
                  ChannelsCapsuleContent(
                    controller: controller,
                    title: 'Canali capsule',
                    subtitle: 'Pillole residue durante il conteggio',
                  ),
                  const SizedBox(height: 14),
                  AppPrimaryButton(
                    label: state.timer > 0 && state.isAutoLoop
                        ? 'STOP AUTO-START'
                        : 'START CONTEGGIO',
                    icon: state.timer > 0 && state.isAutoLoop
                        ? Icons.pause_circle
                        : Icons.play_arrow_rounded,
                    onPressed: controller.onStart,
                    height: 64,
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
