import 'package:flutter/material.dart';
import '../controllers/cpe_vib_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/app_exit_dialog.dart';
import 'config_page.dart';
import 'connection_page.dart';
import 'home_page.dart';

class CpeVibShellPage extends StatefulWidget {
  const CpeVibShellPage({super.key});

  @override
  State<CpeVibShellPage> createState() => _CpeVibShellPageState();
}

class _CpeVibShellPageState extends State<CpeVibShellPage> {
  static const int _pagesCount = 3;

  late final CpeVibController _controller;
  late final PageController _pageController;

  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  late final TextEditingController _pezziController;
  late final TextEditingController _seOffController;
  late final TextEditingController _seOnController;
  late final TextEditingController _vibCamController;
  late final TextEditingController _vibTazController;
  late final TextEditingController _ritChController;
  late final TextEditingController _outgoingTextController;

  @override
  void initState() {
    super.initState();

    _controller = CpeVibController.create();
    _pageController = PageController(initialPage: 0);

    final initial = _controller.state;

    _hostController = TextEditingController(text: initial.host);
    _portController = TextEditingController(text: initial.port);
    _pezziController = TextEditingController(text: '${initial.params.pezzi}');
    _seOffController = TextEditingController(text: '${initial.params.seOff}');
    _seOnController = TextEditingController(text: '${initial.params.seOn}');
    _vibCamController = TextEditingController(text: '${initial.params.vibCam}');
    _vibTazController = TextEditingController(text: '${initial.params.vibTaz}');
    _ritChController = TextEditingController(text: '${initial.params.ritCh}');
    _outgoingTextController =
        TextEditingController(text: initial.outgoingText);

    _controller.addListener(_syncControllersFromState);
    _controller.init();
  }

  void _syncControllersFromState() {
    final state = _controller.state;

    void sync(TextEditingController c, String value) {
      if (c.text != value) {
        c.value = c.value.copyWith(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );
      }
    }

    sync(_hostController, state.host);
    sync(_portController, state.port);
    sync(_pezziController, '${state.params.pezzi}');
    sync(_seOffController, '${state.params.seOff}');
    sync(_seOnController, '${state.params.seOn}');
    sync(_vibCamController, '${state.params.vibCam}');
    sync(_vibTazController, '${state.params.vibTaz}');
    sync(_ritChController, '${state.params.ritCh}');
    sync(_outgoingTextController, state.outgoingText);
  }

  @override
  void dispose() {
    _controller.removeListener(_syncControllersFromState);
    _controller.disposeController();
    _controller.dispose();

    _pageController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _pezziController.dispose();
    _seOffController.dispose();
    _seOnController.dispose();
    _vibCamController.dispose();
    _vibTazController.dispose();
    _ritChController.dispose();
    _outgoingTextController.dispose();

    super.dispose();
  }

  void _goToPage(int i) {
    if (i < 0) i = 0;
    if (i > _pagesCount - 1) i = _pagesCount - 1;
    if (i == _controller.state.pageIndex) return;

    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );

    _controller.setPageIndex(i);
  }

  Future<void> _handleMenuSelection(String value) async {
    if (value == 'exit') {
      final ok = await AppExitDialog.show(context);
      if (ok) {
        await _controller.performExit();
      }
      return;
    }

    if (value == 'timer') {
      final selected = await _pickTimerDialog(
        context,
        initial: _controller.state.timer,
      );
      if (selected != null) {
        _controller.setTimerValue(selected);
      }
      return;
    }

    if (value == 'exp') {
      _controller.toggleExpMode();
      return;
    }
  }

  Future<int?> _pickTimerDialog(
      BuildContext context, {
        required int initial,
      }) {
    return showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Auto-Start (0–9 sec.)'),
        children: List.generate(10, (i) {
          final isSelected = i == initial;
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, i),
            child: Row(
              children: [
                if (isSelected) const Icon(Icons.check, size: 16),
                if (isSelected) const SizedBox(width: 6),
                Text(i == 0 ? '0 (No auto-start)' : '$i sec.'),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _bindFieldListeners() {
    _pezziController.addListener(() {
      _controller.setPezzi(int.tryParse(_pezziController.text) ?? 0);
    });
    _seOffController.addListener(() {
      _controller.setSeOff(int.tryParse(_seOffController.text) ?? 0);
    });
    _seOnController.addListener(() {
      _controller.setSeOn(int.tryParse(_seOnController.text) ?? 0);
    });
    _vibCamController.addListener(() {
      _controller.setVibCam(int.tryParse(_vibCamController.text) ?? 0);
    });
    _vibTazController.addListener(() {
      _controller.setVibTaz(int.tryParse(_vibTazController.text) ?? 0);
    });
    _ritChController.addListener(() {
      _controller.setRitCh(int.tryParse(_ritChController.text) ?? 0);
    });
  }

  bool _fieldListenersBound = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fieldListenersBound) {
      _bindFieldListeners();
      _fieldListenersBound = true;
    }
  }

  String _titleForPage(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return 'CPE-VIB • Collegamento';
      case 1:
        return 'CPE-VIB • Home';
      case 2:
        return 'CPE-VIB • Configurazione';
      default:
        return 'CPE-VIB';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final state = _controller.state;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final ok = await AppExitDialog.show(context);
            if (ok) {
              await _controller.performExit();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: state.isConnected
                  ? AppColors.success
                  : AppColors.primary,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: state.isConnected
                        ? const [AppColors.primary, AppColors.success]
                        : const [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              title: Text(_titleForPage(state.pageIndex)),
              actions: [
                if (state.pageIndex == 1 && state.timer != 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: (state.isInAutoDelay && !state.delayBlinkOn)
                            ? 0.2
                            : 1.0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                PopupMenuButton<String>(
                  tooltip: 'Menu',
                  onSelected: _handleMenuSelection,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'timer',
                      child: Text('AUTO-START (Timer)'),
                    ),
                    PopupMenuItem(
                      value: 'exp',
                      child: Row(
                        children: [
                          Icon(
                            state.settings.expMode
                                ? Icons.visibility_off
                                : Icons.construction,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            state.settings.expMode
                                ? 'Nascondi funzioni avanzate'
                                : 'Mostra funzioni avanzate',
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'exit',
                      child: Row(
                        children: [
                          Icon(Icons.exit_to_app),
                          SizedBox(width: 8),
                          Text('Esci da APP'),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        state.activeTerminal != null
                            ? 'T${state.activeTerminal}'
                            : '--',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: PageView(
                controller: _pageController,
                onPageChanged: _controller.setPageIndex,
                children: [
                  ConnectionPage(
                    controller: _controller,
                    hostController: _hostController,
                    portController: _portController,
                  ),
                  HomePage(
                    controller: _controller,
                    pezziController: _pezziController,
                  ),
                  ConfigPage(
                    controller: _controller,
                    pezziController: _pezziController,
                    seOffController: _seOffController,
                    seOnController: _seOnController,
                    vibCamController: _vibCamController,
                    vibTazController: _vibTazController,
                    ritChController: _ritChController,
                    outgoingTextController: _outgoingTextController,
                  ),
                ],
              ),
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: state.pageIndex,
              onDestinationSelected: _goToPage,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.link_outlined),
                  selectedIcon: Icon(Icons.link),
                  label: 'Link',
                ),
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.tune_outlined),
                  selectedIcon: Icon(Icons.tune),
                  label: 'Config',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}