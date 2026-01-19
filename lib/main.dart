// 
// vers.2.5
// 
// 

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


//===============================================
void main() {
  runApp(const CpeVibApp());
}

//===============================================
class CpeVibApp extends StatelessWidget {
  const CpeVibApp({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CPE-VIB Serial-BT',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

//===============================================
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

//===============================================
class _MyHomePageState extends State<MyHomePage> {
  bool _awaitingStart = false;

  bool xERROR = false;

  bool _paramBusy = false;

  String? _pendingImpostaEcho;

  // 0 = Connessione, 1 = Home, 2 = Config
  int _pageIndex = 0;

  // Wi-Fi TCP
  bool _useWifi = true;  //false;
  Socket? _wifiSock;
  StreamSubscription<List<int>>? _wifiSub;

  // --- Multiterminal WiFi support (TERM-1..3) ---
  final Map<int, Socket> _termSocks = {};
  final Map<int, StreamSubscription<List<int>>> _termSubs = {};
  int? _activeTerm; // terminal attivo (1,2,3)

  final _hostCtrl = TextEditingController(text: '192.168.1.1');
  final _portCtrl = TextEditingController(text: '5000');

  bool get _isConnected => _useWifi ? (_wifiSock != null) : false;

  // Parametri
  final _pezziCtrl = TextEditingController();
  final _SE_OFFCtrl = TextEditingController();
  int _canValue = 6; // 1,2,3,6
  int _formValue = 1; // 1=PERLE, 2=NORMALE, 3=XMINI
  final _SE_ONCtrl = TextEditingController();
  final _vibCamCtrl = TextEditingController();
  final _vibTazCtrl = TextEditingController();
  final _ritChCtrl = TextEditingController();
  final _invTextCtrl = TextEditingController();
  final List<String> _menuAux = const ['aux1','aux2','aux3','aux4','aux5','aux6','aux7','aux8'];
  String _menuSelected = 'Timer: 0';

  // Log / RX
  final List<String> _log = [];
  final StringBuffer _rxBuffer = StringBuffer();

  // CON_M
  bool _conMode = false;
  Timer? _pollTimer;
  bool _waitingProbe = false;

  // START
  bool _startSent = false;
  Timer? _startTimer;
  int _timer = 0;               // 0..9 (0 = nessun auto-riavvio)
  bool _autoLoop = false;       // true quando il loop automatico è attivo
  Timer? _autoRestartTimer;     // timer di attesa per il riavvio automatico
  // --- Segnalazione "ritardo auto-riavvio" (pallino rosso + beep) ---
  Timer? _delaySignalTimer;     // lampeggio/beep a 1 Hz durante il ritardo
  bool _delayBlinkOn = true;    // stato lampeggio pallino
  bool _inAutoDelay = false;    // true mentre stiamo aspettando il riavvio automatico
  // --- START result & UI ---
  String? _lastStartFrame;
  bool? _lastStartOk;
  String _c1 = '', _c2 = '', _c3 = '', _c4 = '', _c5 = '', _c6 = '';
  int? _unita;
  Completer<bool>? _impostaCompleter;

//===========================
  @override
  void initState() {
    _lastStartOk = true;
    _unita = 0;

    super.initState();
  }

//===========================
  @override
  void dispose() {
    _pollTimer?.cancel();
    _startTimer?.cancel();
    _autoRestartTimer?.cancel();
    _delaySignalTimer?.cancel();

    _hostCtrl.dispose();
    _portCtrl.dispose();

    _pezziCtrl.dispose();
    _SE_OFFCtrl.dispose();
    _SE_ONCtrl.dispose();
    _vibCamCtrl.dispose();
    _vibTazCtrl.dispose();
    _ritChCtrl.dispose();
    _invTextCtrl.dispose();
    super.dispose();
  }


// Ritorna true x permettere l'uscita, false per bloccarla
//===============================================
Future<bool> _onBackPressed() async {
  if (!mounted) return true;

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      
      backgroundColor:  const Color(0xFFEEEEEE), // grigio chiaro  const Color(0xFF7F0E18) , // grigio chiaro

      title: const Text('CHIUDERE APP ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Sì'),
        ),
      ],
    ),
  );
                                //quiesce
  if (ok == true) {
    // Chiudi app
    if (Platform.isAndroid) {

    try {
      await _onDisMPressed();
      await _disconnect();
    } catch (_) {}
    SystemNavigator.pop();   // metodo "pulito" per Android
    } else {
      exit(0); // fallback per altri casi
    }
    return true;
  }
  return false;
}


 // Snack helper

  // Menu 3 puntini (overflow) handler
Future<void> _onMenuSelected(String value) async {
  if (value == 'exit') {
    // Riusa la stessa logica del back (chiusura pulita)
    await _onBackPressed();
    return;
  }

  // Voce TIMER: apre un dialog per scegliere 0..9
  if (value == 'timer') {
    final v = await _pickTimerDialog(context, initial: _timer);
    if (v != null) {
      setState(() {
        _timer = v;
        _menuSelected = 'Timer: $v';
      });
    }
    return;
  }

  // Gestisci selezioni AUX rimanenti
  setState(() {
    _menuSelected = value;
  });

  // Esempio di reazione ad una voce AUX
  if (value == 'aux3') {
    await _sendAscii('TtT');
  }
}

Future<int?> _pickTimerDialog(BuildContext context, {required int initial}) {
  return showDialog<int>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: const Text('Timer (0–9 secondi)'),
      children: List.generate(10, (i) {
        final isSel = i == initial;
        return SimpleDialogOption(
          onPressed: () => Navigator.pop(ctx, i),
          child: Row(
            children: [
              if (isSel) const Icon(Icons.check, size: 16),
              if (isSel) const SizedBox(width: 6),
              Text(i == 0 ? '0 (default – no auto)' : '$i secondi'),
            ],
          ),
        );
      }),
    ),
  );
}
//===============================================

  void _showSnack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }


// Log helper
//===============================================
  void _logAdd(String s) {
    if (!mounted) return;
    setState(() {
      _log.insert(0, '${DateTime.now().toIso8601String().substring(11, 19)}  $s');
    });
  }


// LINK-ON / LINK-OFF
//===============================================
Future<void> _connect() async {
    
    if (_useWifi) {
      // Multiterminal connect: base from Host/IP, then .101, .102, .103
      final host = _hostCtrl.text.trim();
      final port = int.tryParse(_portCtrl.text) ?? 333;
      final base = _deriveBaseFromHost(host);
      _logAdd('WiFi: connessione ai terminali $base.101/.102/.103 ...');

      final results = await _wifiConnectTermsFromBase(base, port, timeout: const Duration(milliseconds: 900));
      final onTerms = [for (final e in results.entries) if (e.value) e.key]..sort();
      final offTerms = [for (final e in results.entries) if (!e.value) e.key]..sort();

//	ALLERT BOX CONNESSIONE
//
//      await showDialog<void>(
//        context: context,
//        builder: (ctx) {
//          return AlertDialog(
//            title: const Text('Esito conness. WiFi'),
//            content: Column(
//              mainAxisSize: MainAxisSize.min,
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: [
//                Text('ON : ' + (onTerms.isEmpty ? '-' : onTerms.map((e)=>'TERM-$e').join(', '))),
//                const SizedBox(height: 4),
//                Text('OFF: ' + (offTerms.isEmpty ? '-' : offTerms.map((e)=>'TERM-$e').join(', '))),
//              ],
//            ),
//            actions: [
//              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
//            ],
//          );
//        },
//      );
//


      if (onTerms.isEmpty) {
        _logAdd('WiFi: nessun terminale raggiungibile.');
        _showSnack('Nessun terminale ON');
        setState(() { _wifiSock = null; });
        return;
      }

      _activeTerm = onTerms.first; // terminale con numero più basso
      _wifiSock = _termSocks[_activeTerm];
      _logAdd('WiFi: attivo TERM-${_activeTerm}.');

      await SystemSound.play(SystemSoundType.click);    //BEEP

      return;
    }
    

  }


//===============================================
// DISCONNETTE    wifi
//===============================================
Future<void> _disconnect() async {


    // Chiudi tutte le connessioni WiFi multiple
    try {
      for (final sub in _termSubs.values) { await sub.cancel(); }
    } catch (_) {}
    try {
      for (final s in _termSocks.values) { await s.close(); }
    } catch (_) {}
    _termSubs.clear();
    _termSocks.clear();
    _activeTerm = null;
    
    try {
      await _sendAscii('<');
      await Future.delayed(const Duration(milliseconds: 60));
      await _sendAscii('<');
      await Future.delayed(const Duration(milliseconds: 60));
      await _sendAscii('<');
    } catch (_) {}

    // WiFi cleanup if used
    try { _wifiSub?.cancel(); } catch (_) {}
    try { _wifiSock?.flush(); } catch (_) {}
    try { _wifiSock?.close(); } catch (_) {}
    _wifiSock = null;

    if (!mounted) return;
    setState(() {});
  }

//===============================================
// TX Testi ASCII
//===============================================
Future<void> _sendAscii(String s) async {
     if (!_isConnected) {
       _showSnack('Non connesso');
       return;
     }
    try {
      if (_useWifi) {
        _wifiSock!.add(ascii.encode(s));   //EX utf8.encode(s));
        await _wifiSock!.flush();
      }
      _logAdd('TX: ' + s.replaceAll('\n', '\\n').replaceAll('\r', '\\r'));
    } catch (e) {
      _logAdd('Errore TX: ' + e.toString());
    }
  }


//===============================================
// RICEZIONE TESTO
//===============================================
  void _onBytes(Uint8List data) {
    final chunk = ascii.decode(data, allowInvalid: true);   //EX utf8.decode(data, allowMalformed: true);
    if (_impostaCompleter != null && !(_impostaCompleter!.isCompleted)) {
      final match = RegExp(r'[A-Za-z]').firstMatch(chunk);
      if (match != null) {
        final first = match.group(0);
        if (first == 'A') {
          _impostaCompleter!.complete(true);
        } else {
          _impostaCompleter!.complete(false);
        }
      }
    }
    _rxBuffer.write(chunk);

    if (_waitingProbe && chunk.isNotEmpty) {
      _waitingProbe = false;
      _stopConMode(keepButtonState: true);
    }

    while (true) {
      final text = _rxBuffer.toString();
      final i = text.indexOf('*');
     if (i < 0) break;
      final frame = text.substring(0, i);


      _logAdd('RX: $frame*');

      // SCARTO ECO IMPOSTA: consumare il frame prima del continue
      if (_pendingImpostaEcho != null) {
        _pendingImpostaEcho = null;
        _rxBuffer.clear();
        _rxBuffer.write(text.substring(i + 1)); // avanza oltre '*'
        continue; // ora davvero scartato
      }
  
      if (frame.startsWith('A') || frame.startsWith('X')) {
        _parseStartResult(frame);
      } else {
        _parseAndFill(frame);
      }

      _rxBuffer.clear();
      _rxBuffer.write(text.substring(i + 1));
    }

  }

  // Parsing posizioni (0-based, senza '*'):
  // [0-2]=Pezzi, [18-20]=SE_OFF, [4]=Form, [15-17]=SE_ON, [6-8]=%Vib Can, [9-11]=%Vib Taz, [12-15]=RitCH
  String _safeSub(String s, int a, int b) {
    if (a < 0 || b <= a || a >= s.length) return '';
    if (b > s.length) b = s.length;
    return s.substring(a, b);
  }

//===============================================
//===============================================
  void _handleAorXFrame(String ft) {
    // aggiorna le capsule SOLO subito dopo START
    if (_awaitingStart && ft.length >= 10) {
      _parseStartResult(ft);
      _awaitingStart = false;
      return;
    }
    // altrimenti considera come info/echo/ack e non toccare capsule
    _parseAndFill(ft);
  }




//    if (_awaitingStart && ft.length >= 10) {
//      _parseStartResult(ft);
//      _awaitingStart = false;
//      return;
//    }

//===============================================
//*********** ESTRAE PARAMETRI CANALI ***********
//===============================================
void _parseStartResult(String frame) {
    if (frame.isEmpty) return;
    final ok = frame.startsWith('A');
    final s = frame;
    String safeChar(int idx) => (idx >= 0 && idx < s.length) ? s[idx] : '';
    int? safeNum(int a, int b) {
      if (a < 0 || a >= s.length) return null;
      if (b > s.length) b = s.length;
      return int.tryParse(s.substring(a, b));
    }

     final c1 = safeChar(1);
     final c2 = safeChar(2);
     final c3 = safeChar(3);
     final c4 = safeChar(4);
     final c5 = safeChar(5);
     final c6 = safeChar(6);
     final unita = safeNum(7, 10);

    setState(() {
      _lastStartFrame = s;
      _lastStartOk = ok;
      if (s.length >= 10) {
      _c1 = c1; _c2 = c2; _c3 = c3; _c4 = c4; _c5 = c5; _c6 = c6;
       }
      _unita = unita ?? _unita;
    });
// Auto-riavvio se attivo e TIMER > 0
if (_autoLoop && _timer > 0) {
  _autoRestartTimer?.cancel();
  _startDelaySignal();
  _autoRestartTimer = Timer(Duration(seconds: _timer), () {
    if (!mounted) return;
    if (!_autoLoop) return;     // auto fermato dall'utente
    if (!_isConnected) return;  // connessione persa
    _stopDelaySignal();

    _sendAscii('S');            // riparte come se avessi premuto START
    setState(() => _startSent = true);
    _startTimer?.cancel();
    _startTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _startSent = false);
    });
  });
}
  }


//======================================================================
// Segnale durante il ritardo prima dell'auto-riavvio (lampeggio + suono)
//======================================================================
  void _startDelaySignal() {
    if (_delaySignalTimer != null) return; // già attivo
    _inAutoDelay = true;
    _delayBlinkOn = true;
    _delaySignalTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted) return;
      // Suono a ritmo di 1 secondo (alcuni device non riproducono "alert")
      try {
        // Prova 1: click (più compatibile su Android)
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {
        // ignora
      }
      // Fallback: feedback aptico (non sostituisce il suono ma dà conferma)
      try {
        HapticFeedback.selectionClick();
      } catch (_) {
        // ignora
      }
      setState(() => _delayBlinkOn = !_delayBlinkOn);
    });
  }

  void _stopDelaySignal() {
    _delaySignalTimer?.cancel();
    _delaySignalTimer = null;
    if (!mounted) return;
    setState(() {
      _inAutoDelay = false;
      _delayBlinkOn = true; // quando non lampeggia, rimane acceso fisso
    });
  }
//===============================================
//****** ESTRAE PARAMETRI INIZIALI **************  
//===============================================
void _parseAndFill(String frame) {
    int? p(String s) => int.tryParse(s.trim());

    final frameSan = frame.replaceAll('>', '').replaceAll('<', '');
//    final frameSan = frame;
// >0901091092095094093*

    final pezzi = p(_safeSub(frameSan, 0, 3));
    final form = p(_safeSub(frameSan, 3, 4));
    final vibC = p(_safeSub(frameSan, 4, 7));
    final vibT = p(_safeSub(frameSan, 7, 10));
    final ritch = p(_safeSub(frameSan, 10, 13));
    final SE_ON = p(_safeSub(frameSan, 13, 16));
    final SE_OFF = p(_safeSub(frameSan, 16, 19));



    setState(() {
      if (pezzi != null) _pezziCtrl.text = pezzi.toString();
      if (SE_OFF != null) _SE_OFFCtrl.text = SE_OFF.toString();
      if (form != null) _formValue = form;
      if (SE_ON != null) _SE_ONCtrl.text = SE_ON.toString();
      if (vibC != null) _vibCamCtrl.text = vibC.toString();
      if (vibT != null) _vibTazCtrl.text = vibT.toString();
      if (ritch != null) _ritChCtrl.text = ritch.toString();
    });
  }

//===========================================
// CON_M / DIS_M    LINK-ON / LINK-OFF
//===========================================
  Future<void> _toggleConMode() async {
     if (!_isConnected) {
       _showSnack('Non connesso');
       return;
     }
    if (_conMode) {
      await _onDisMPressed();
    } else {
      _startConMode();
    }
  }

  
//===============================================
//**** LINK-OFF ** PROCEDURA DI DIS_MACCHINA ****
//===============================================
Future<void> _onDisMPressed() async {
  try {
    if (_isConnected) {
      for (int i = 0; i < 2; i++) {
        await _sendAscii('<');
        await Future.delayed(const Duration(milliseconds: 60));
      }
     }
  } catch (_) {}
  _stopConMode();
}

//===============================================
//*** LINK-ON ** PROCEDURA DI CONNES_MACCHINA ***
//===============================================
void _startConMode() {
    _pollTimer?.cancel();
    _conMode = true;
    _waitingProbe = true;
    _pollTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
       if (!_isConnected) {
         _stopConMode();
         return;
       }
      if (_waitingProbe) _sendAscii('>');
    });
    setState(() {});
  }


//*******************************************************************
// SCONNESSIONE MACCHINA
//*******************************************************************
  void _stopConMode({bool keepButtonState = false}) {
    _autoLoop = false;
    _autoRestartTimer?.cancel();
    _stopDelaySignal();
    _pollTimer?.cancel();
    _pollTimer = null;
    _waitingProbe = false;
    if (!keepButtonState) _conMode = false;
    setState(() {});
  }

//===============================================
// START CONTEGGIO
//===============================================
void _onStart() {
   if (!_isConnected) {
     _showSnack('Non connesso');
     return;
   }

   // TIMER == 0 -> comportamento originale (singolo ciclo)
   if (_timer == 0) {
     _sendAscii('S');
     setState(() => _startSent = true);
     _startTimer?.cancel();
     _startTimer = Timer(const Duration(seconds: 1), () {
       if (mounted) setState(() => _startSent = false);
     });
     return;
   }

   // TIMER > 0 -> START diventa toggle per l'auto-loop
   if (_autoLoop) {
     // Fermiamo il loop automatico
     _autoLoop = false;
     _autoRestartTimer?.cancel();
     _stopDelaySignal();
     _showSnack('Auto-START fermato');
     setState(() => _startSent = false);
     return;
   } else {
     // Avviamo il loop automatico e mandiamo subito il primo START
     _autoLoop = true;
     _sendAscii('S');
     setState(() => _startSent = true);
     _startTimer?.cancel();
     _startTimer = Timer(const Duration(seconds: 1), () {
       if (mounted) setState(() => _startSent = false);
     });
   }
}



@override
//===============================================

Widget build(BuildContext context) {
  return PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) async {
      if (didPop) return;
      final ok = await _onBackPressed();
      if (ok && context.mounted) Navigator.of(context).maybePop(result);
    },
    child: Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        // Cambia il colore di background in base a _isConnected
        backgroundColor: _isConnected ? const Color(0xFF4CAF50) : const Color(0xFF9E9E9E),
        foregroundColor: Colors.white,
        
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // Cambia il gradiente in base a _isConnected
              colors: _isConnected
                  ? [Color(0xFF0D47A1), Color(0xFF4CAF50)]  // Blu e verde
                  : [Color(0xFF0D47A1), Color(0xFF9E9E9E)],  // Blu e grigio
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),


        title: Text(_pageIndex == 0
            ? 'CPE-VIB - Vers.2.5'
            : _pageIndex == 1
                ? 'CPE-VIB - Home'
                : 'CPE-VIB - Config.'),
        actions: [
          // Pallino rosso (Home): visibile quando TIMER != 0; lampeggia + beep durante il ritardo auto-riavvio
          if (_pageIndex == 1 && _timer != 0)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: (_inAutoDelay && !_delayBlinkOn) ? 0.15 : 1.0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          PopupMenuButton<String>(
            tooltip: 'Menu',
            onSelected: _onMenuSelected,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'timer', child: Text('Timer')),
              const PopupMenuItem(value: 'aux2', child: Text('aux2')),
              const PopupMenuItem(value: 'aux3', child: Text('aux3')),
              const PopupMenuItem(value: 'aux4', child: Text('aux4')),
              const PopupMenuItem(value: 'aux5', child: Text('aux5')),
              const PopupMenuItem(value: 'aux6', child: Text('aux6')),
              const PopupMenuItem(value: 'aux7', child: Text('aux7')),
              const PopupMenuItem(value: 'aux8', child: Text('aux8')),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'exit',
                child: Row(
                  children: const [
                    Icon(Icons.exit_to_app),
                    SizedBox(width: 8),
                    Text('Esci'),
                  ],
                ),
              ),
            ],
          ),
    
          // Puoi aggiungere azioni qui se necessario

	    Padding(
	      padding: const EdgeInsets.only(right: 12),
	      child: Container(
	        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
	        decoration: BoxDecoration(
	          color: Colors.black26,
	          borderRadius: BorderRadius.circular(12),
	        ),
	        child: Text(
        	  _activeTerm != null ? 'T${_activeTerm}' : '--',
	          style: const TextStyle(
        	    color: Colors.white,
	            fontWeight: FontWeight.bold,
        	    fontSize: 16,
	            letterSpacing: 0.5,
	          ),
	        ),
	      ),
	    ),
	  ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _pageIndex,
          children: [
            _buildPageConn(), // 0
            _buildHome(), // 1
            _buildConfigPage(), // 2
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pageIndex,
        onDestinationSelected: (i) => setState(() => _pageIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.link), label: 'Link'),
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Config'),
        ],
      ),
    ),
  );
}

//===============================================
// Pagina 1 (Connessione)
//===============================================
  Widget _buildPageConn() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  SizedBox(
                    height: 100, //TL 120,
                    child: Image.asset(
                      'assets/images/CPEV_t.BMP',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text('Logo non disponibile',
                            style: TextStyle(color: Colors.black54)),
                      ),
                    ),
                  ),
                //TL  const SizedBox(height: 6),
                //TL  const Text('CPE-VIB',
                //TL      style:
                //TL          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          _termChoiceChips(),			//SELETTORE TERMINALE ATTIVO

//ff          _transportSelectorCard(),    //SELETTORE WIFI

          const SizedBox(height: 12),
          _useWifi ? _wifiConfigCard() : _wifiConfigCard(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 74, //TL84,			//ALTEZZA PULS.CONNTTI
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                           _isConnected ? const Color(0xFF4CAF50) : const Color(0xFF9E9E9E),
                      foregroundColor: Colors.white,
                    ),
                     onPressed: _isConnected ? _disconnect : _connect,
                    child: Text( _isConnected ? 'WiFi-ON' : 'WiFi-OFF',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 65),		//SPAZIO TRA BOTTONI
          SizedBox(
            height: 44,
            width: double.infinity,
            child: SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
//-------------------------------------------------------------------------------------
  

//************************************************************************
// SELEZIONE  BLUETHOOT / WIFI
//************************************************************************
  Widget _transportSelectorCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            const Text('Tipo Conn.:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Wi-Fi'),
              selected: _useWifi,
              onSelected: (v) => setState(() => _useWifi = true),
            ),
          ],
        ),
      ),
    );
  }


//===============================================
  Widget _wifiConfigCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Wi-Fi (TCP)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hostCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Host / IP',
                      filled: true,
                      hintText: '192.168.1.1 o sxlink-xxxx.local',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _portCtrl,
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
            const SizedBox(height: 3), //TL 4),
            //TL const Text('Nota: serve android.permission.INTERNET nel Manifest.',
            //TL  style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

//===============================================
// Pagina 2 (Home)
//===============================================
  Widget _buildHome() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barre affiancate
              Row(
                children: [
                  Expanded(child: SizedBox(height: 64, child: _startResultBanner())),
                  const SizedBox(width: 8),
                  Expanded(child: SizedBox(height: 64, child: _unitBanner())),
                ],
              ),
              const SizedBox(height: 8),
              _capsuleView(),
              const SizedBox(height: 8),
              // Spacer per tenere i controlli nella metà  inferiore
              const Expanded(child: SizedBox.shrink()),
              Transform.translate(offset: const Offset(0, -24), child: Column(children: [
// Pezzi + SE_OFF
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.66,
                        child: _numField('Pezzi', _pezziCtrl, 1, 999),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _onImpostaPressed,
                      child: const Text('IMPOSTA'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // CON_M e START tondo
              // CON_M e START tondo

//ff              _termChoiceChips(),		// SCELTA TERMINALE ATTIVO

              const SizedBox(height: 8),
Row(
  children: [
    Expanded(
      child: SizedBox(
        height: 44,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _conMode ? Colors.yellow : const Color(0xFF455A64),
            foregroundColor: _conMode ? Colors.black : Colors.white,
          ),
          onPressed: _toggleConMode,
          child: Text(_conMode ? 'LINK-ON' : 'LINK-OFF'),
        ),
      ),
    ),
    const SizedBox(width: 8),
    SizedBox(
      width: 192,
      height: 96,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(const StadiumBorder()),
          fixedSize: WidgetStateProperty.all(const Size(192, 96)),

          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.pressed) ? Colors.yellow  : const Color(0xFF9B111E), //EX : Colors.red,
          ),
          foregroundColor: WidgetStateProperty.all(Colors.white),
        ),
        onPressed: _onStart,
        child: const Text('START', textAlign: TextAlign.center),
      ),
    ),
  ],
),
              const SizedBox(height: 16),
              
            ])),// PARAM in fondo
              SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

//===============================================
// Pagina 3 (Config)
//===============================================
  Widget _buildConfigPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          SizedBox(height: 8),
          const SizedBox(height: 15), 		 // SPAZIO SOPRA
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
              _numField('Pezzi', _pezziCtrl, 1, 999),
              _numField('%Vib_C', _vibCamCtrl, 1, 100),
              _numField('%Vib_T', _vibTazCtrl, 1, 100),
              _dropdownForm(),
//              _dropdownCan(),
              _numField('SE_OFF', _SE_OFFCtrl, 1, 255),
              _numField('SE_ON', _SE_ONCtrl, 1, 255),
              _numField('RitCH', _ritChCtrl, 1, 255),               //AGGIUNTO 
              _BUTT_Config2(),
              _BUTT_Config1(),
            ],
          ),
          const SizedBox(height: 68),					// SPAZIO TRA PARAMETRI E TESTO DA INVIARE

          _termChoiceChips(),				// SCELTA TERMINALE ATTIVO

          const SizedBox(height: 8),

//*****************************************************************************
//   SCOMMENTARE X INVIO TESTO
//*****************************************************************************
          Row(
            children: [
              Expanded(
                flex: 5,
                child: TextField(
                  controller: _invTextCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Testo da inviare',
                    filled: true,
                  ),
                  onSubmitted: (_) async { await _sendAscii(_invTextCtrl.text); _invTextCtrl.clear(); },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async { await _sendAscii(_invTextCtrl.text); _invTextCtrl.clear(); },
                    child: const Text('INV-C'),
                  ),
                ),
              ),
            ],
         ),
//*****************************************************************************
//   SCOMMENTARE X INVIO TESTO
//*****************************************************************************


          const SizedBox(height: 8),
          _logView(),
          const SizedBox(height: 12),
          SizedBox.shrink(),
        ],
      ),
    );
  }

//---------------------------------------------------------------------------------------------



  Future<bool> _waitImpostaAck(Duration timeout) async {
    _impostaCompleter?.complete(false);
    _impostaCompleter = Completer<bool>();
    final timer = Timer(timeout, () {
      if (!(_impostaCompleter!.isCompleted)) {
        _impostaCompleter!.complete(false);
      }
    });
    final ok = await _impostaCompleter!.future;
    timer.cancel();
    _impostaCompleter = null;
    return ok;
  }

  // Widgets comuni



//===============================================
  

//===============================================

  Future<void> _onImpostaPressed() async {
    final pezzi = int.tryParse(_pezziCtrl.text) ?? -1;
    if (pezzi < 1 || pezzi > 999) { _showError('Pezzi deve essere 1..999'); return; }
//    if (![1,2,3,6].contains(_SE_OFFValue)) { _showError('SE_OFF deve essere 1,2,3 o 6'); return; }

    _awaitingStart = false;

    try {
      await _sendAscii('C');
      final ok = await _waitImpostaAck(const Duration(milliseconds: 1500));
      if (ok) {
        final pezzi = int.tryParse(_pezziCtrl.text) ?? 0;
        final pezzi3 = pezzi.clamp(1, 999).toString().padLeft(3, '0');
//        final SE_OFF1 = (_SE_OFFValue ?? 1).toString();
        await _sendAscii(pezzi3 + 'P');
      }
    } catch (_) {}
  }


 // --- CONFIG sequence: ParamTX ---
//===============================================
  
  bool _validateRanges() {
    final pezzi = int.tryParse(_pezziCtrl.text) ?? -1;
    if (pezzi < 1 || pezzi > 999) { _showError('Pezzi deve essere 1..999'); return false; }

   //ex   if (![1,2,3,6].contains(_SE_OFFValue)) { _showError('SE_OFF deve essere 1, 2, 3 o 6'); return false; }

    if (!([1,2,3].contains(_formValue))) { _showError('Form deve essere 1..3'); return false; }

    final SE_OFF = int.tryParse(_SE_OFFCtrl.text) ?? -1;
    if (SE_OFF < 1 || SE_OFF > 255) { _showError('SE_OFF deve essere 1..255'); return false;  }


    final SE_ON = int.tryParse(_SE_ONCtrl.text) ?? -1;
    if (SE_ON < 1 || SE_ON > 255) { _showError('SE_ON deve essere 1..255'); return false;  }

    final vibc = int.tryParse(_vibCamCtrl.text) ?? -1;
    final vibt = int.tryParse(_vibTazCtrl.text) ?? -1;
    final rit = int.tryParse(_ritChCtrl.text) ?? -1;

    if (vibc < 1 || vibc > 100) { _showError('%Vib Can deve essere 1..100'); return false; }
    if (vibt < 1 || vibt > 100) { _showError('%Vib Taz deve essere 1..100'); return false; }
    if (rit  < 1 || rit  > 255) { _showError('RitCH deve essere 1..255'); return false; }

    return true;
  }

//===============================================

  void _showError(String msg) {
    xERROR = true;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

//===============================================
// TRASMETTE I PARAMETRI IN SEQ.
//===============================================
Future<void> _paramTX1() async {
    if (!_validateRanges()) return;

    _awaitingStart = false;
    bool okAll = true;
    if (_paramBusy) return;
    setState(() { _paramBusy = true; xERROR = false; });

    // Step 1: C -> A -> send Pezzi(3) + Can(1) -> expect echo -> wait 0.5s
    final pezzi = int.tryParse(_pezziCtrl.text) ?? 0;
    final pezzi3 = pezzi.clamp(1, 999).toString().padLeft(3, '0');
//    final can1 = (_canValue ?? 1).toString();
//    okAll = okAll && 
await _TX_Com(pezzi3 + 'P');

    // Step 2: C -> A -> send '00' + Form + 'F'
    final form1 = _formValue.toString();
//    okAll = okAll && 
await _TX_Com('00' + form1 + 'F');

    // Step 3: C -> A -> send  SE_ON + 'Y'
    final SE_ON = int.tryParse(_SE_ONCtrl.text) ?? 0;
    final SE_ON1 = SE_ON.clamp(0, 255).toString().padLeft(3, '0');
//    okAll = okAll && 
await _TX_Com(SE_ON1 + 'Y');

    // Step 3: C -> A -> send  SE_OFF + 'N'
    final SE_OFF = int.tryParse(_SE_OFFCtrl.text) ?? 0;
    final SE_OFF1 = SE_OFF.clamp(0, 255).toString().padLeft(3, '0');
//    okAll = okAll && 
await _TX_Com(SE_OFF1 + 'N');


    // Step 4: C -> A -> send Vib Can + 'V'
    final vibC = int.tryParse(_vibCamCtrl.text) ?? 0;
    final vibCtxt = vibC.clamp(1, 100).toString().padLeft(3, '0');
//    okAll = okAll && 
await _TX_Com(vibCtxt + 'V');

    // Step 5: C -> A -> send Vib Taz + 'T'
    final vibT = int.tryParse(_vibTazCtrl.text) ?? 0;
    final vibTtxt = vibT.clamp(1, 100).toString().padLeft(3, '0');
//    okAll = okAll && 
await _TX_Com(vibTtxt + 'T');

//    // Step 6: C -> A -> send RitCH + 'R'
//    final rit = int.tryParse(_ritChCtrl.text) ?? 0;
//    final ritTxt = rit.clamp(1, 255).toString().padLeft(3, '0');
// //    okAll = okAll && 
//await _TX_Com(ritTxt + 'R');
  
    if (!okAll) {
      xERROR = true;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ERRORE'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    if (mounted) setState(() { _paramBusy = false; });
}




//===============================================
// TRASMETTE I PARAMETRI IN SEQ.
//===============================================
Future<void> _paramTX2() async {
    if (!_validateRanges()) return;

    _awaitingStart = false;
    bool okAll = true;
    if (_paramBusy) return;
    setState(() { _paramBusy = true; xERROR = false; });


    // Step 6: C -> A -> send RitCH + 'R'
    final rit = int.tryParse(_ritChCtrl.text) ?? 0;
    final ritTxt = rit.clamp(1, 255).toString().padLeft(3, '0');
//    okAll = okAll && 
await _TX_Com(ritTxt + 'R');
  
    if (!okAll) {
      xERROR = true;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ERRORE'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    if (mounted) setState(() { _paramBusy = false; });
}


//************************************************************************
//************************************************************************  
Widget _BUTT_Config1() {
  return Row(
    children: [
      const Spacer(), // spinge il bottone a destra
      SizedBox(
        height: 40,
        width: 100, // larghezza fissa
          child: ElevatedButton(
         // style: ElevatedButton.styleFrom(foregroundColor: Colors.green, backgroundColor: Colors.red.shade100),

          onPressed: _paramBusy ? null : _paramTX1,
          child: _paramBusy
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('SET_All'),
        ),
      ),
      const SizedBox(width: 18), // spazio sotto il CONFIG
    ],
  );
}

//************************************************************************
//************************************************************************  
Widget _BUTT_Config2() {
  return Row(
    children: [
      const Spacer(), // spinge il bottone a destra
      SizedBox(
        height: 40,
        width: 100, // larghezza fissa


//    Positioned(
//      left: 24,  // X
//      top:  80,  // Y

          child: ElevatedButton(
          style: ElevatedButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Colors.red.shade200),

          onPressed: _paramBusy ? null : _paramTX2,
          child: _paramBusy
            ? const SizedBox(width: 18, height: 18 )
            : const Text('SET_Rit'),
        ),
     
      ),
      const SizedBox(width: 18),  // spazio sotto il CONFIG
    ],
  );
}






//===============================================
  
Future<bool> _TX_Com(String payload) async {
    try {
      await _sendAscii('C');
      final ok1 = await _waitImpostaAck(const Duration(milliseconds: 1500));
      if (!ok1) return false;
      _pendingImpostaEcho = 'A' + payload + '*';
      await _sendAscii(payload);
      final ok2 = await _waitImpostaAck(const Duration(milliseconds: 1500));
      await Future.delayed(const Duration(milliseconds: 500));
      return ok2;
    } catch (e) {
      _logAdd('CONFIG errore: ' + e.toString());
      return false;
    }
  }

//===============================================

  Widget _startResultBanner() {
    final ok = _lastStartOk == true;
    final pezziText = _pezziCtrl.text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ok ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(ok ? 'OK' : 'KO', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
          const SizedBox(width: 8),
          Text('Pz: ' + pezziText,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        ],
      ),
    );
  }

//===============================================
  Widget _unitBanner() {
    final un = _unita ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF546E7A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('UN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
          const SizedBox(width: 8),
          Text('$un', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        ],
      ),
    );
  }

//===============================================
//  VIS CPS CANALI
//===============================================
Widget _capsuleView() {
  final show6 = (_canValue == 6);
  final values = [_c1, _c2, _c3, _c4, _c5, _c6];
  final toShow = show6 ? values : values.take(3).toList();

  Widget pill(String txt) {
    return Container(
      width: 43,
      height: 96,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
        ),
        border: Border.all(color: Color(0xFFBDBDBD)),
        boxShadow: const [
          BoxShadow(color: Colors.white70, offset: Offset(-2, -2), blurRadius: 4, spreadRadius: 1),
          BoxShadow(color: Colors.black26, offset: Offset(3, 3), blurRadius: 6, spreadRadius: 1),
        ],
      ),
      child: Text(txt, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    );
  }

  return Padding(
    padding: const EdgeInsets.only(top: 19),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: toShow.map((c) => pill(c)).toList(),
      ),
    ),
  );
}



//===============================================
// gestione TERMINALE ATTIVO
//===============================================
  Widget _termChoiceChips() {
    // Versione con checkbox ultra-compatti 
    Widget cek(String label, int n) {
      final sel = _activeTerm == n;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: 0.95,  //85, // più piccolo possibile senza perdere tap
            child: Checkbox(
              value: sel,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (_) => _setActiveTerm(n),
            ),
          ),
          GestureDetector(
            onTap: () => _setActiveTerm(n),
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
        ],
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            const Text('Terminale attivo', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 8),
            cek('T1', 1),
            const SizedBox(width: 8),
            cek('T2', 2),
            const SizedBox(width: 8),
            cek('T3', 3),
          ],
        ),
      ),
    );
  }


//===============================================

void _setActiveTerm(int n) {
    setState(() {
      _activeTerm = n;
      if (_useWifi) {
        if (_termSocks.containsKey(n)) {
          _wifiSock = _termSocks[n];
          _logAdd('WiFi: attivo TERM-$n.');
        } else {
          // Mantieni l'attuale _wifiSock ma avvisa che il TERM non è connesso
          _logAdd('WiFi: TERM-$n non connesso.');
        }
      }
    });
  }

//===============================================
Widget _numField(String label, TextEditingController ctrl, int min, int max) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: '$label',    //ex  '$label ($min-$max)',
        filled: true,

        fillColor: label == 'RitCH' ? Colors.red.shade200 : null, // [ADDED]

      ),
    );
  }

////===============================================
//  Widget _dropdownCan() {
//    const allowed = [1, 2, 3, 6];
//    final value = allowed.contains(_canValue) ? _canValue : 1;
//    return InputDecorator(
//      decoration:
//          const InputDecoration(labelText: 'Canali', filled: true),
//      child: DropdownButtonHideUnderline(
//        child: DropdownButton<int>(
//          isExpanded: true,
//          value: value,
//          items: allowed
//              .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
//              .toList(),
//          onChanged: (v) => setState(() => _canValue = v ?? 1),
//        ),
//      ),
//    );
//  }

//===============================================
  Widget _dropdownForm() {
    const items = [
      DropdownMenuItem(value: 1, child: Text('1-PERLE')),
      DropdownMenuItem(value: 2, child: Text('2-NORM')),
      DropdownMenuItem(value: 3, child: Text('3-XMINI')),
    ];
    final value = [1, 2, 3].contains(_formValue) ? _formValue : 1;
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Form', filled: true),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: value,
          items: items,
          onChanged: (v) => setState(() => _formValue = v ?? 1),
        ),
      ),
    );
  }


//===============================================
//  FINESTRA LOG
//===============================================
  Widget _logView() {
    return Container(
      constraints: const BoxConstraints(minHeight: 120, maxHeight: 120),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFBDBDBD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _log.isEmpty
          ? const Text('Log vuoto...', style: TextStyle(color: Colors.black54))
          : ListView.builder(
              reverse: true,
              itemCount: _log.length,
              itemBuilder: (_, i) => Text(_log[i]),
            ),
    );
  }
//-----------------------------------------------------------------


  String _deriveBaseFromHost(String host) {
    host = host.trim();
    final m = RegExp(r'^(\d+)\.(\d+)\.(\d+)\.(\d+)$').firstMatch(host);
    if (m != null) {
      return '${m.group(1)}.${m.group(2)}.${m.group(3)}';
    }
    final m3 = RegExp(r'^(\d+)\.(\d+)\.(\d+)$').firstMatch(host);
    if (m3 != null) {
      return m3.group(0)!;
    }
    return '192.168.1';
  }

//===============================================

  Future<Map<int,bool>> _wifiConnectTermsFromBase(String base, int port, {Duration timeout = const Duration(milliseconds: 800)}) async {
    final results = <int,bool>{1:false,2:false,3:false};
    // Chiude eventuali connessioni precedenti
    for (final sub in _termSubs.values) { try { await sub.cancel(); } catch (_) {} }
    for (final s in _termSocks.values)   { try { await s.close(); } catch (_) {} }
    _termSubs.clear();
    _termSocks.clear();

    for (final n in [1,2,3]) {
      final ip = '$base.${100+n}';
      try {
        final sock = await Socket.connect(ip, port, timeout: timeout);
        final sub = sock.listen((data) {
          if (_activeTerm == n) {
            _onBytes(Uint8List.fromList(data));
          }
        }, onDone: () {
          if (_activeTerm == n) _logAdd('WiFi $n: connessione chiusa.');
          _termSocks.remove(n);
          _termSubs.remove(n);
          if (_activeTerm == n && mounted) {
            setState(() { _wifiSock = null; });
          }
        }, onError: (e) {
          _logAdd('WiFi $n errore: $e');
        });
        _termSocks[n] = sock;
        _termSubs[n] = sub;
        results[n] = true;
      } catch (_) {
        results[n] = false;
      }
    }
    return results;
  }

}