import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WifiConfigCard extends StatelessWidget {
  final TextEditingController hostController;
  final TextEditingController portController;
  final ValueChanged<String> onHostChanged;
  final ValueChanged<String> onPortChanged;

  const WifiConfigCard({
    super.key,
    required this.hostController,
    required this.portController,
    required this.onHostChanged,
    required this.onPortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Wi-Fi (TCP)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: hostController,
                    onChanged: onHostChanged,
                    decoration: const InputDecoration(
                      labelText: 'Host / IP',
                      filled: true,
                      hintText: '192.168.1.101 o sxlink-xxxx.local',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: portController,
                    onChanged: onPortChanged,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
    );
  }
}