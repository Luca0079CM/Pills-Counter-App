import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/app_settings.dart';

class SettingsLocalDatasource {
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      expMode: prefs.getBool('exp_mode') ?? false,
      sixChannelsMode: prefs.getBool('six_channels') ?? true,
    );
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('exp_mode', settings.expMode);
    await prefs.setBool('six_channels', settings.sixChannelsMode);
  }
}