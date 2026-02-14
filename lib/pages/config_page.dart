import 'package:flutter/material.dart';

class ConfigPage extends StatelessWidget {
  final TextEditingController pezziCtrl;
  final TextEditingController vibCamCtrl;
  final TextEditingController vibTazCtrl;
  final TextEditingController seOffCtrl;
  final TextEditingController seOnCtrl;
  final TextEditingController ritChCtrl;
  final TextEditingController invTextCtrl;

  final int formValue;
  final ValueChanged<int?> onFormChanged;
  final VoidCallback onSendText;
  final VoidCallback onSendAll;
  final VoidCallback onSendRit;

  final bool paramBusy;
  final Widget terminalSelector;
  final Widget logView;

  const ConfigPage({
    super.key,
    required this.pezziCtrl,
    required this.vibCamCtrl,
    required this.vibTazCtrl,
    required this.seOffCtrl,
    required this.seOnCtrl,
    required this.ritChCtrl,
    required this.invTextCtrl,
    required this.formValue,
    required this.onFormChanged,
    required this.onSendText,
    required this.onSendAll,
    required this.onSendRit,
    required this.paramBusy,
    required this.terminalSelector,
    required this.logView,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          GridView(
            shrinkWrap: true,
            physics:
            const NeverScrollableScrollPhysics(),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.8,
            ),
            children: [
              _numField('Pezzi', pezziCtrl),
              _numField('%Vib_C', vibCamCtrl),
              _numField('%Vib_T', vibTazCtrl),
              _dropdownForm(),
              _numField('SE_OFF', seOffCtrl),
              _numField('SE_ON', seOnCtrl),
              _numField('RitCH', ritChCtrl),
              _buttonSetRit(),
              _buttonSetAll(),
            ],
          ),
          const SizedBox(height: 20),
          terminalSelector,
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: TextField(
                  controller: invTextCtrl,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Testo da inviare',
                    filled: true,
                  ),
                  onSubmitted: (_) =>
                      onSendText(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: onSendText,
                    child:
                    const Text('INV-C'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          logView,
        ],
      ),
    );
  }

  Widget _numField(
      String label,
      TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
      ),
    );
  }

  Widget _dropdownForm() {
    return InputDecorator(
      decoration: const InputDecoration(
          labelText: 'Form',
          filled: true),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: formValue,
          isExpanded: true,
          items: const [
            DropdownMenuItem(
                value: 1,
                child: Text('1-PERLE')),
            DropdownMenuItem(
                value: 2,
                child: Text('2-NORM')),
            DropdownMenuItem(
                value: 3,
                child: Text('3-XMINI')),
          ],
          onChanged: onFormChanged,
        ),
      ),
    );
  }

  Widget _buttonSetAll() {
    return ElevatedButton(
      onPressed:
      paramBusy ? null : onSendAll,
      child: paramBusy
          ? const CircularProgressIndicator(
          strokeWidth: 2)
          : const Text('SET_All'),
    );
  }

  Widget _buttonSetRit() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor:
          Colors.red.shade200,
          foregroundColor:
          Colors.black),
      onPressed:
      paramBusy ? null : onSendRit,
      child: const Text('SET_Rit'),
    );
  }
}
