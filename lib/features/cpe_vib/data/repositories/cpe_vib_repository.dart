import '../datasources/settings_local_datasource.dart';
import '../datasources/wifi_datasource.dart';
import '../../domain/entities/app_settings.dart';

class CpeVibRepository {
  final WifiDatasource wifiDatasource;
  final SettingsLocalDatasource settingsDatasource;

  CpeVibRepository({
    required this.wifiDatasource,
    required this.settingsDatasource,
  });

  Future<AppSettings> loadSettings() => settingsDatasource.load();

  Future<void> saveSettings(AppSettings settings) =>
      settingsDatasource.save(settings);

  Future<Map<int, bool>> connectTerms({
    required String baseIp,
    required int port,
    required void Function(int terminal, dynamic data) onData,
    required void Function(int terminal) onDone,
    required void Function(int terminal, Object error) onError,
    Duration timeout = const Duration(milliseconds: 800),
  }) {
    return wifiDatasource.connectTerms(
      baseIp: baseIp,
      port: port,
      onData: onData,
      onDone: onDone,
      onError: onError,
      timeout: timeout,
    );
  }

  void setActiveTerminal(int terminal) {
    wifiDatasource.setActiveTerminal(terminal);
  }

  bool hasTerminal(int terminal) => wifiDatasource.hasTerminal(terminal);

  bool get isConnected => wifiDatasource.isConnected;

  Future<void> sendAscii(String value) => wifiDatasource.sendAscii(value);

  Future<void> disconnect() => wifiDatasource.disconnectAll();
}