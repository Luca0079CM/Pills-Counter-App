class CommandBuilder {
  const CommandBuilder();

  String start() => 'S';
  String probe() => '>';
  String disconnectMachine() => '<';
  String configHandshake() => 'C';
  String refreshParams() => 'i';

  String pezzi(int value) => value.clamp(1, 999).toString().padLeft(3, '0') + 'P';

  String form(int value) => '00${value.clamp(1, 3)}F';

  String seOn(int value) => value.clamp(0, 255).toString().padLeft(3, '0') + 'Y';

  String seOff(int value) => value.clamp(0, 255).toString().padLeft(3, '0') + 'N';

  String vibCam(int value) => value.clamp(1, 100).toString().padLeft(3, '0') + 'V';

  String vibTaz(int value) => value.clamp(1, 100).toString().padLeft(3, '0') + 'T';

  String ritCh(int value) => value.clamp(1, 255).toString().padLeft(3, '0') + 'R';
}