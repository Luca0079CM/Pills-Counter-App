import 'package:flutter/material.dart';
import '../controllers/cpe_vib_controller.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = controller.state;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 100,
                child: Image.asset(
                  'assets/images/CPEV_t.BMP',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text(
                      'Logo non disponibile',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (state.settings.expMode)
            TerminalSelector(
              activeTerminal: state.activeTerminal,
              onSelected: controller.setActiveTerminal,
            ),
          if (state.settings.expMode) const SizedBox(height: 12),
          if (state.settings.expMode)
            WifiConfigCard(
              hostController: hostController,
              portController: portController,
              onHostChanged: controller.setHost,
              onPortChanged: controller.setPort,
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 74,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: state.isConnected
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF9E9E9E),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: state.isConnected
                        ? controller.disconnect
                        : controller.connect,
                    child: Text(
                      state.isConnected ? 'WiFi-ON' : 'WiFi-OFF',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 65),
          const SizedBox(
            height: 44,
            width: double.infinity,
            child: SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}