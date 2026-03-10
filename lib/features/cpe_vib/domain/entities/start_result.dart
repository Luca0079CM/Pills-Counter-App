class StartResult {
  final bool ok;
  final String rawFrame;
  final List<String> channels;
  final int unita;

  const StartResult({
    required this.ok,
    required this.rawFrame,
    required this.channels,
    required this.unita,
  });

  factory StartResult.initial() {
    return const StartResult(
      ok: true,
      rawFrame: '',
      channels: ['', '', '', '', '', ''],
      unita: 0,
    );
  }

  StartResult copyWith({
    bool? ok,
    String? rawFrame,
    List<String>? channels,
    int? unita,
  }) {
    return StartResult(
      ok: ok ?? this.ok,
      rawFrame: rawFrame ?? this.rawFrame,
      channels: channels ?? this.channels,
      unita: unita ?? this.unita,
    );
  }
}