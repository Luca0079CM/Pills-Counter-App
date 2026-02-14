import 'package:flutter/material.dart';

import 'connect_page.dart';
import 'config_page.dart';

import '../widgets/terminal_selector.dart';
import '../widgets/start_banner.dart';
import '../widgets/unit_banner.dart';
import '../widgets/capsule_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;

  bool _isConnected = false;
  bool _conMode = false;
  bool _lastStartOk = true;

  final TextEditingController _pezziCtrl =
  TextEditingController(text: '100');

  final List<String> _capsules = ['0', '0', '0', '0', '0', '0'];
  int _unit = 0;

  final TextEditingController _vibCamCtrl = TextEditingController();
  final TextEditingController _vibTazCtrl = TextEditingController();
  final TextEditingController _seOffCtrl = TextEditingController();
  final TextEditingController _seOnCtrl = TextEditingController();
  final TextEditingController _ritChCtrl = TextEditingController();
  final TextEditingController _invTextCtrl = TextEditingController();

  int _formValue = 1;
  final bool _paramBusy = false;

  final List<String> _log = [];
  int _activeTerm = 1;

  final TextEditingController _hostCtrl =
  TextEditingController(text: '192.168.1.1');
  final TextEditingController _portCtrl =
  TextEditingController(text: '5000');

  @override
  void dispose() {
    _pezziCtrl.dispose();
    _vibCamCtrl.dispose();
    _vibTazCtrl.dispose();
    _seOffCtrl.dispose();
    _seOnCtrl.dispose();
    _ritChCtrl.dispose();
    _invTextCtrl.dispose();
    _hostCtrl.dispose();
    _portCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _pageIndex == 0
              ? 'CPE-VIB - Connessione'
              : _pageIndex == 1
              ? 'CPE-VIB - Home'
              : 'CPE-VIB - Config.',
        ),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _pageIndex,
          children: [
            ConnectPage(
              isConnected: _isConnected,
              hostController: _hostCtrl,
              portController: _portCtrl,
              onConnectPressed: _toggleConnection,
              terminalSelector: TerminalSelector(
                active: _activeTerm,
                onChanged: (n) => setState(() => _activeTerm = n),
              ),
            ),
            _buildHomePage(),
            ConfigPage(
              pezziCtrl: _pezziCtrl,
              vibCamCtrl: _vibCamCtrl,
              vibTazCtrl: _vibTazCtrl,
              seOffCtrl: _seOffCtrl,
              seOnCtrl: _seOnCtrl,
              ritChCtrl: _ritChCtrl,
              invTextCtrl: _invTextCtrl,
              formValue: _formValue,
              onFormChanged: (v) => setState(() => _formValue = v ?? 1),
              onSendText: _onSendText,
              onSendAll: _onSendAll,
              onSendRit: _onSendRit,
              paramBusy: _paramBusy,
              terminalSelector: TerminalSelector(
                active: _activeTerm,
                onChanged: (n) => setState(() => _activeTerm = n),
              ),
              logView: _buildLogView(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pageIndex,
        onDestinationSelected: (i) =>
            setState(() => _pageIndex = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.link), label: 'Link'),
          NavigationDestination(
              icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.tune), label: 'Config'),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StartBanner(
                  ok: _lastStartOk,
                  pezzi: _pezziCtrl.text,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: UnitBanner(unit: _unit),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CapsuleView(capsules: _capsules),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pezziCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Pezzi',
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _onImposta,
                child: const Text('IMPOSTA'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _conMode
                        ? Colors.yellow
                        : const Color(0xFF455A64),
                    foregroundColor: _conMode
                        ? Colors.black
                        : Colors.white,
                  ),
                  onPressed: _toggleConMode,
                  child: Text(
                      _conMode ? 'LINK-ON' : 'LINK-OFF'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 180,
                height: 90,
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                        const StadiumBorder()),
                    backgroundColor:
                    WidgetStateProperty.all(
                        const Color(0xFF9B111E)),
                  ),
                  onPressed: _onStart,
                  child: const Text('START'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleConnection() {
    setState(() => _isConnected = !_isConnected);
  }

  void _toggleConMode() {
    setState(() => _conMode = !_conMode);
  }

  void _onStart() {
    setState(() {
      _lastStartOk = !_lastStartOk;
      _unit++;
      _capsules.shuffle();
    });
  }

  void _onImposta() {}

  void _onSendText() {
    final txt = _invTextCtrl.text.trim();
    if (txt.isEmpty) return;
    _log.insert(0, txt);
    _invTextCtrl.clear();
    setState(() {});
  }

  void _onSendAll() {}
  void _onSendRit() {}

  Widget _buildLogView() {
    return Container(
      constraints:
      const BoxConstraints(minHeight: 120, maxHeight: 120),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
            color: const Color(0xFFBDBDBD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _log.isEmpty
          ? const Text('Log vuoto...')
          : ListView.builder(
        reverse: true,
        itemCount: _log.length,
        itemBuilder: (_, i) =>
            Text(_log[i]),
      ),
    );
  }
}
