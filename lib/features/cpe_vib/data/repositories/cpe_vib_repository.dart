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

  Future<bool> connect({
    required String host,
    required int port,
    required void Function(dynamic data) onData,
    required void Function() onDone,
    required void Function(Object error) onError,
    Duration timeout = const Duration(milliseconds: 900),
  }) {
    return wifiDatasource.connect(
      host: host,
      port: port,
      onData: onData,
      onDone: onDone,
      onError: onError,
      timeout: timeout,
    );
  }

  bool get isConnected => wifiDatasource.isConnected;

  Future<void> sendAscii(String value) => wifiDatasource.sendAscii(value);

  Future<void> disconnect() => wifiDatasource.disconnectAll();
}