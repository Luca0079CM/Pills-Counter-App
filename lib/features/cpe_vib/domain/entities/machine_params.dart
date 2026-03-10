class MachineParams {
  final int pezzi;
  final int seOff;
  final int seOn;
  final int vibCam;
  final int vibTaz;
  final int ritCh;
  final int formValue;
  final List<String> capsules;

  const MachineParams({
    required this.pezzi,
    required this.seOff,
    required this.seOn,
    required this.vibCam,
    required this.vibTaz,
    required this.ritCh,
    required this.formValue,
    required this.capsules,
  });

  factory MachineParams.initial() {
    return const MachineParams(
      pezzi: 1,
      seOff: 1,
      seOn: 1,
      vibCam: 1,
      vibTaz: 1,
      ritCh: 1,
      formValue: 1,
      capsules: ['', '', '', '', '', ''],
    );
  }

  MachineParams copyWith({
    int? pezzi,
    int? seOff,
    int? seOn,
    int? vibCam,
    int? vibTaz,
    int? ritCh,
    int? formValue,
    List<String>? capsules,
  }) {
    return MachineParams(
      pezzi: pezzi ?? this.pezzi,
      seOff: seOff ?? this.seOff,
      seOn: seOn ?? this.seOn,
      vibCam: vibCam ?? this.vibCam,
      vibTaz: vibTaz ?? this.vibTaz,
      ritCh: ritCh ?? this.ritCh,
      formValue: formValue ?? this.formValue,
      capsules: capsules ?? this.capsules,
    );
  }
}