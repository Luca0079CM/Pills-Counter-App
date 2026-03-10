import 'package:flutter/material.dart';
import '../controllers/cpe_vib_controller.dart';
import '../widgets/capsule_view.dart';
import '../widgets/numeric_input_field.dart';
import '../widgets/start_result_banner.dart';
import '../widgets/unit_banner.dart';

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

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 64,
                      child: StartResultBanner(
                        ok: state.startResult.ok,
                        pezzi: state.params.pezzi,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 64,
                      child: UnitBanner(unita: state.unita),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CapsuleView(
                values: state.params.capsules,
                showSix: state.settings.sixChannelsMode,
              ),
              const SizedBox(height: 8),
              const Expanded(child: SizedBox.shrink()),
              Transform.translate(
                offset: const Offset(0, -24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: 0.66,
                              child: NumericInputField(
                                label: 'Pezzi',
                                controller: pezziController,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: controller.onImpostaPressed,
                            child: const Text('IMPOSTA'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: state.isConMode
                                    ? Colors.yellow
                                    : const Color(0xFF455A64),
                                foregroundColor: state.isConMode
                                    ? Colors.black
                                    : Colors.white,
                              ),
                              onPressed: controller.toggleConMode,
                              child: Text(
                                state.isConMode ? 'LINK-ON' : 'LINK-OFF',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 192,
                          height: 96,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(
                                const StadiumBorder(),
                              ),
                              fixedSize: WidgetStateProperty.all(
                                const Size(192, 96),
                              ),
                              backgroundColor:
                              WidgetStateProperty.resolveWith<Color?>(
                                    (states) => states.contains(WidgetState.pressed)
                                    ? Colors.yellow
                                    : const Color(0xFF9B111E),
                              ),
                              foregroundColor:
                              WidgetStateProperty.all(Colors.white),
                            ),
                            onPressed: controller.onStart,
                            child: const Text(
                              'START',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }
}