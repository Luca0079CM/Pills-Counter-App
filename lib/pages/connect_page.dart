import 'package:flutter/material.dart';

class ConnectPage extends StatelessWidget {
  final bool isConnected;
  final TextEditingController hostController;
  final TextEditingController portController;
  final VoidCallback onConnectPressed;
  final Widget terminalSelector;

  const ConnectPage({
    super.key,
    required this.isConnected,
    required this.hostController,
    required this.portController,
    required this.onConnectPressed,
    required this.terminalSelector,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text(
                    'Wi-Fi (TCP)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: hostController,
                          decoration: const InputDecoration(
                            labelText: 'Host / IP',
                            filled: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: portController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Porta',
                            filled: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          terminalSelector,
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isConnected
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF9E9E9E),
                foregroundColor: Colors.white,
              ),
              onPressed: onConnectPressed,
              child: Text(
                isConnected ? 'WiFi-ON' : 'WiFi-OFF',
                style: const TextStyle(
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
