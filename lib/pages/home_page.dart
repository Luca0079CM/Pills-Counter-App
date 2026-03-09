import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // -----------------------------
  // CONTROLLERS
  // -----------------------------
  final TextEditingController _pezziCtrl =
  TextEditingController(text: '100');

  // -----------------------------
  // STATE
  // -----------------------------
  bool _lastStartOk = true;
  bool _conMode = false;

  final List<String> _capsules =
  ['0', '0', '0', '0', '0', '0'];

  int _unit = 0;

  // -----------------------------
  // COUNTDOWN INDUSTRIALE
  // -----------------------------
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _countdownTimer;

  int _secondsRemaining = 0;
  int _timerValue = 5; // <-- qui imposti i secondi (esempio 5)

  bool _isFlashing = false;
  bool _flashState = false;

  // -----------------------------
  @override
  void dispose() {
    _countdownTimer?.cancel();
    _audioPlayer.dispose();
    _pezziCtrl.dispose();
    super.dispose();
  }

  // -----------------------------
  // START COUNTDOWN INDUSTRIALE
  // -----------------------------
  void _startIndustrialCountdown(int seconds) {
    _countdownTimer?.cancel();

    _secondsRemaining = seconds;
    _isFlashing = true;
    _flashState = true;

    setState(() {});

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) async {
        if (!mounted) return;

        if (_secondsRemaining <= 0) {
          timer.cancel();
          _stopIndustrialCountdown();
          _executeStart();
          return;
        }

        // 🔊 Beep forte reale
        await _audioPlayer.play(
          AssetSource('audio/beep.wav'),
          volume: 1.0,
        );

        setState(() {
          _secondsRemaining--;
          _flashState = !_flashState;
        });
      },
    );
  }

  // -----------------------------
  void _stopIndustrialCountdown() {
    _countdownTimer?.cancel();
    _isFlashing = false;
    _flashState = false;
    _secondsRemaining = 0;
    setState(() {});
  }

  // -----------------------------
  // ESECUZIONE START REALE
  // -----------------------------
  void _executeStart() {
    setState(() {
      _lastStartOk = !_lastStartOk;
      _unit++;
      _capsules.shuffle();
    });
  }

  // -----------------------------
  void _onStartPressed() {
    if (_secondsRemaining > 0) return;

    if (_timerValue > 0) {
      _startIndustrialCountdown(_timerValue);
    } else {
      _executeStart();
    }
  }

  // -----------------------------
  void _toggleConMode() {
    setState(() => _conMode = !_conMode);
  }

  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isFlashing
          ? (_flashState
          ? Colors.red.shade200
          : Colors.white)
          : Colors.white,
      appBar: AppBar(
        title: const Text('CPE-VIB - Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [

            // -----------------------------
            // COUNTDOWN DISPLAY
            // -----------------------------
            if (_isFlashing)
              Container(
                padding: const EdgeInsets.all(16),
                margin:
                const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius:
                  BorderRadius.circular(8),
                ),
                child: Text(
                  '$_secondsRemaining',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight:
                    FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

            // -----------------------------
            // BANNER OK / KO
            // -----------------------------
            Container(
              padding:
              const EdgeInsets.symmetric(
                  vertical: 12),
              decoration: BoxDecoration(
                color: _lastStartOk
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFC62828),
                borderRadius:
                BorderRadius.circular(8),
              ),
              child: Text(
                _lastStartOk ? 'OK' : 'KO',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // -----------------------------
            // CAPSULE VIEW
            // -----------------------------
            Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: _capsules
                  .map((c) => Container(
                width: 40,
                height: 80,
                margin:
                const EdgeInsets.symmetric(
                    horizontal: 6),
                alignment:
                Alignment.center,
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(
                      24),
                  color: Colors
                      .grey.shade300,
                ),
                child: Text(
                  c,
                  style:
                  const TextStyle(
                    fontSize: 24,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ))
                  .toList(),
            ),

            const Spacer(),

            // -----------------------------
            // PEZZI
            // -----------------------------
            TextField(
              controller: _pezziCtrl,
              keyboardType:
              TextInputType.number,
              decoration:
              const InputDecoration(
                labelText: 'Pezzi',
                filled: true,
              ),
            ),

            const SizedBox(height: 12),

            // -----------------------------
            // BOTTONI
            // -----------------------------
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      _conMode
                          ? Colors.yellow
                          : const Color(
                          0xFF455A64),
                      foregroundColor:
                      _conMode
                          ? Colors.black
                          : Colors.white,
                    ),
                    onPressed:
                    _toggleConMode,
                    child: Text(
                      _conMode
                          ? 'LINK-ON'
                          : 'LINK-OFF',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 180,
                  height: 90,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape:
                      MaterialStateProperty
                          .all(
                        const StadiumBorder(),
                      ),
                      backgroundColor:
                      MaterialStateProperty
                          .all(
                        const Color(
                            0xFF9B111E),
                      ),
                    ),
                    onPressed:
                    _onStartPressed,
                    child:
                    const Text('START'),
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
