import 'package:flutter/material.dart';
import '../controllers/cpe_vib_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/log_panel.dart';
import '../widgets/numeric_input_field.dart';
import '../widgets/terminal_selector.dart';
import '../widgets/common/app_page_padding.dart';
import '../widgets/common/app_primary_button.dart';
import '../widgets/common/app_secondary_button.dart';
import '../widgets/common/app_section_card.dart';
import '../widgets/common/app_section_header.dart';

class ConfigPage extends StatelessWidget {
  final CpeVibController controller;
  final TextEditingController pezziController;
  final TextEditingController seOffController;
  final TextEditingController seOnController;
  final TextEditingController vibCamController;
  final TextEditingController vibTazController;
  final TextEditingController ritChController;
  final TextEditingController outgoingTextController;

  const ConfigPage({
    super.key,
    required this.controller,
    required this.pezziController,
    required this.seOffController,
    required this.seOnController,
    required this.vibCamController,
    required this.vibTazController,
    required this.ritChController,
    required this.outgoingTextController,
  });

  Future<void> _showValidationDialog(
      BuildContext context, {
        required String title,
        required String message,
      }) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _validatePercentageField(
      BuildContext context, {
        required TextEditingController controller,
        required String fieldLabel,
      }) async {
    final text = controller.text.trim();

    if (text.isEmpty) {
      await _showValidationDialog(
        context,
        title: 'Valore non valido',
        message: '$fieldLabel deve essere compreso tra 1 e 100.',
      );
      return;
    }

    final value = int.tryParse(text);

    if (value == null || value < 1 || value > 100) {
      await _showValidationDialog(
        context,
        title: 'Valore non valido',
        message: '$fieldLabel deve essere compreso tra 1 e 100.',
      );
    }
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionHeader(
                    title: 'Parametri principali',
                    subtitle: 'Configurazione operativa del conteggio',
                    icon: Icons.settings,
                  ),
                  const SizedBox(height: 16),
                  _ResponsiveFieldsGrid(
                    children: [
                      NumericInputField(
                        label: 'Pezzi',
                        controller: pezziController,
                      ),
                      NumericInputField(
                        label: 'Percentuale Vibr. Piatto',
                        controller: vibCamController,
                        onSubmitted: (_) => _validatePercentageField(
                          context,
                          controller: vibCamController,
                          fieldLabel: 'Percentuale Vibr. Piatto',
                        ),
                        onTapOutside: (_) => _validatePercentageField(
                          context,
                          controller: vibCamController,
                          fieldLabel: 'Percentuale Vibr. Piatto',
                        ),
                      ),
                      NumericInputField(
                        label: 'Percentuale Vibr. Tramolgia',
                        controller: vibTazController,
                        onSubmitted: (_) => _validatePercentageField(
                          context,
                          controller: vibTazController,
                          fieldLabel: 'Percentuale Vibr. Tramolgia',
                        ),
                        onTapOutside: (_) => _validatePercentageField(
                          context,
                          controller: vibTazController,
                          fieldLabel: 'Percentuale Vibr. Tramolgia',
                        ),
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
                            AppPrimaryButton(
                              label: 'Invia configurazione',
                              icon: Icons.save,
                              onPressed: state.isParamBusy
                                  ? null
                                  : controller.sendConfigSet1,
                            ),
                            const SizedBox(height: 12),
                            AppSecondaryButton(
                              label: 'Invia solo RitCH',
                              icon: Icons.timer,
                              onPressed: state.isParamBusy
                                  ? null
                                  : controller.sendConfigSetRit,
                              backgroundColor: const Color(0xFFFFE5E5),
                              foregroundColor: AppColors.danger,
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: AppPrimaryButton(
                              label: 'Invia configurazione',
                              icon: Icons.save,
                              onPressed: state.isParamBusy
                                  ? null
                                  : controller.sendConfigSet1,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppSecondaryButton(
                              label: 'Invia solo RitCH',
                              icon: Icons.timer,
                              onPressed: state.isParamBusy
                                  ? null
                                  : controller.sendConfigSetRit,
                              backgroundColor: const Color(0xFFFFE5E5),
                              foregroundColor: AppColors.danger,
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
                    title: 'Modalità avanzata',
                    subtitle: 'Abilita o disabilita le funzioni tecniche',
                    icon: Icons.construction,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    value: state.settings.expMode,
                    onChanged: (_) => controller.toggleExpMode(),
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Funzioni avanzate (EXP)',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      state.settings.expMode
                          ? 'Le opzioni avanzate sono visibili'
                          : 'Le opzioni avanzate sono nascoste',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (state.settings.expMode) ...[
              const SizedBox(height: AppSpacing.section),
              AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionHeader(
                      title: 'Parametri avanzati',
                      subtitle: 'Controlli tecnici ed esperti',
                      icon: Icons.tune,
                    ),
                    const SizedBox(height: 16),
                    _ResponsiveFieldsGrid(
                      children: [
                        NumericInputField(
                          label: 'SE_OFF',
                          controller: seOffController,
                        ),
                        NumericInputField(
                          label: 'SE_ON',
                          controller: seOnController,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Terminale attivo',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TerminalSelector(
                      activeTerminal: state.activeTerminal,
                      onSelected: controller.setActiveTerminal,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: outgoingTextController,
                      onChanged: controller.setOutgoingText,
                      decoration: const InputDecoration(
                        labelText: 'Testo da inviare',
                        hintText: 'Comando manuale ASCII',
                      ),
                      onSubmitted: (_) async {
                        await controller.sendAscii(outgoingTextController.text);
                        outgoingTextController.clear();
                        controller.setOutgoingText('');
                      },
                    ),
                    const SizedBox(height: 12),
                    AppSecondaryButton(
                      label: 'Invia comando manuale',
                      icon: Icons.send,
                      onPressed: () async {
                        await controller.sendAscii(outgoingTextController.text);
                        outgoingTextController.clear();
                        controller.setOutgoingText('');
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
                      title: 'Log tecnico',
                      subtitle: 'Tracce di debug della comunicazione',
                      icon: Icons.terminal,
                    ),
                    const SizedBox(height: 16),
                    LogPanel(logs: state.logs),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormDropdown(CpeVibController controller, int value) {
    const items = [
      DropdownMenuItem(value: 1, child: Text('1 - PERLE')),
      DropdownMenuItem(value: 2, child: Text('2 - NORM')),
      DropdownMenuItem(value: 3, child: Text('3 - XMINI')),
    ];

    final safeValue = [1, 2, 3].contains(value) ? value : 1;

    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Form'),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: safeValue,
          items: items,
          onChanged: (v) {
            if (v != null) controller.setFormValue(v);
          },
        ),
      ),
    );
  }
}

class _ResponsiveFieldsGrid extends StatelessWidget {
  final List<Widget> children;

  const _ResponsiveFieldsGrid({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth < 420) {
          crossAxisCount = 2;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 4;
        }

        return GridView.builder(
          shrinkWrap: true,
          itemCount: children.length,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: constraints.maxWidth < 420 ? 1.55 : 1.8,
          ),
          itemBuilder: (_, index) => children[index],
        );
      },
    );
  }
}