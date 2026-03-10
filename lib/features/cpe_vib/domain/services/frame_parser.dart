import '../entities/machine_params.dart';
import '../entities/start_result.dart';

class FrameParser {
  const FrameParser();

  StartResult parseStartResult(String frame, {required int currentUnita}) {
    if (frame.isEmpty) {
      return StartResult.initial().copyWith(unita: currentUnita);
    }

    String safeChar(int idx) => (idx >= 0 && idx < frame.length) ? frame[idx] : '';

    int? safeNum(int a, int b) {
      if (a < 0 || a >= frame.length) return null;
      if (b > frame.length) b = frame.length;
      return int.tryParse(frame.substring(a, b));
    }

    return StartResult(
      ok: frame.startsWith('A'),
      rawFrame: frame,
      channels: [
        safeChar(1),
        safeChar(2),
        safeChar(3),
        safeChar(4),
        safeChar(5),
        safeChar(6),
      ],
      unita: safeNum(7, 10) ?? currentUnita,
    );
  }

  MachineParams parseMachineParams(
      String frame, {
        required MachineParams current,
      }) {
    int? p(String s) => int.tryParse(s.trim());

    String payload = frame;

    final gt = payload.indexOf('>');
    if (gt >= 0) {
      payload = payload.substring(gt + 1);
    }

    final star = payload.indexOf('*');
    if (star >= 0) {
      payload = payload.substring(0, star);
    }

    payload = payload.replaceAll('<', '');
    payload = payload.replaceAll(RegExp(r'[^0-9]'), '');

    if (payload.length < 19) return current;

    String safeSub(String s, int a, int b) {
      if (a < 0 || b <= a || a >= s.length) return '';
      if (b > s.length) b = s.length;
      return s.substring(a, b);
    }

    return current.copyWith(
      pezzi: p(safeSub(payload, 0, 3)) ?? current.pezzi,
      formValue: p(safeSub(payload, 3, 4)) ?? current.formValue,
      vibCam: p(safeSub(payload, 4, 7)) ?? current.vibCam,
      vibTaz: p(safeSub(payload, 7, 10)) ?? current.vibTaz,
      ritCh: p(safeSub(payload, 10, 13)) ?? current.ritCh,
      seOn: p(safeSub(payload, 13, 16)) ?? current.seOn,
      seOff: p(safeSub(payload, 16, 19)) ?? current.seOff,
    );
  }
}