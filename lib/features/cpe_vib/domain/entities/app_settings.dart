class AppSettings {
  final bool expMode;
  final bool sixChannelsMode;

  const AppSettings({
    required this.expMode,
    required this.sixChannelsMode,
  });

  factory AppSettings.initial() {
    return const AppSettings(
      expMode: false,
      sixChannelsMode: true,
    );
  }

  AppSettings copyWith({
    bool? expMode,
    bool? sixChannelsMode,
  }) {
    return AppSettings(
      expMode: expMode ?? this.expMode,
      sixChannelsMode: sixChannelsMode ?? this.sixChannelsMode,
    );
  }
}