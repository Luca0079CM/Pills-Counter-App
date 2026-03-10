import 'package:flutter/material.dart';
import '../controllers/cpe_vib_controller.dart';
import '../widgets/log_panel.dart';
import '../widgets/numeric_input_field.dart';
import '../widgets/terminal_selector.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = controller.state;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const SizedBox(height: 15),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.8,
            ),
            children: [
              NumericInputField(
                label: 'Pezzi',
                controller: pezziController,
              ),
              NumericInputField(
                label: '%Vib_C',
                controller: vibCamController,
              ),
              NumericInputField(
                label: '%Vib_T',
                controller: vibTazController,
              ),
              _buildFormDropdown(controller, state.params.formValue),
              if (state.settings.expMode)
                NumericInputField(
                  label: 'SE_OFF',
                  controller: seOffController,
                ),
              if (state.settings.expMode)
                NumericInputField(
                  label: 'SE_ON',
                  controller: seOnController,
                ),
              NumericInputField(
                label: 'RitCH',
                controller: ritChController,
                fillColor: Colors.red.shade200,
              ),
              _buildSetRitButton(controller, state.isParamBusy),
              _buildSetButton(controller, state.isParamBusy),
            ],
          ),
          const SizedBox(height: 68),
          if (state.settings.expMode)
            TerminalSelector(
              activeTerminal: state.activeTerminal,
              onSelected: controller.setActiveTerminal,
            ),
          if (state.settings.expMode) const SizedBox(height: 8),
          if (state.settings.expMode)
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextField(
                    controller: outgoingTextController,
                    decoration: const InputDecoration(
                      labelText: 'Testo da inviare',
                      filled: true,
                    ),
                    onChanged: controller.setOutgoingText,
                    onSubmitted: (_) async {
                      await controller.sendAscii(outgoingTextController.text);
                      outgoingTextController.clear();
                      controller.setOutgoingText('');
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        await controller.sendAscii(outgoingTextController.text);
                        outgoingTextController.clear();
                        controller.setOutgoingText('');
                      },
                      child: const Text('INV-C'),
                    ),
                  ),
                ),
              ],
            ),
          if (state.settings.expMode) const SizedBox(height: 8),
          if (state.settings.expMode)
            LogPanel(logs: state.logs),
          const SizedBox(height: 12),
          const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildSetButton(CpeVibController controller, bool busy) {
    return Row(
      children: [
        const Spacer(),
        SizedBox(
          height: 40,
          width: 100,
          child: ElevatedButton(
            onPressed: busy ? null : controller.sendConfigSet1,
            child: busy
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('SET'),
          ),
        ),
        const SizedBox(width: 18),
      ],
    );
  }

  Widget _buildSetRitButton(CpeVibController controller, bool busy) {
    return Row(
      children: [
        const Spacer(),
        SizedBox(
          height: 40,
          width: 100,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.red.shade200,
            ),
            onPressed: busy ? null : controller.sendConfigSetRit,
            child: busy
                ? const SizedBox(width: 18, height: 18)
                : const Text('SET_Rit'),
          ),
        ),
        const SizedBox(width: 18),
      ],
    );
  }

  Widget _buildFormDropdown(CpeVibController controller, int value) {
    const items = [
      DropdownMenuItem(value: 1, child: Text('1-PERLE')),
      DropdownMenuItem(value: 2, child: Text('2-NORM')),
      DropdownMenuItem(value: 3, child: Text('3-XMINI')),
    ];

    final safeValue = [1, 2, 3].contains(value) ? value : 1;

    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Form', filled: true),
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