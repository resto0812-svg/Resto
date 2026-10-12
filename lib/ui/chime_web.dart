import 'package:web/web.dart' as web;

web.AudioContext? _ctx;

/// Sur le Web : carillon à deux notes (trois si urgent), sans fichier son.
/// Le navigateur n'autorise le son qu'après une première action de l'utilisateur.
void playChime({bool urgent = false}) {
  try {
    final ctx = _ctx ??= web.AudioContext();
    final notes = urgent ? [880.0, 1175.0, 1568.0] : [988.0, 1319.0];
    var start = ctx.currentTime + 0.02;
    for (final f in notes) {
      final osc = ctx.createOscillator();
      final gain = ctx.createGain();
      osc.type = 'sine';
      osc.frequency.value = f;
      gain.gain.setValueAtTime(0.0001, start);
      gain.gain.exponentialRampToValueAtTime(0.25, start + 0.02);
      gain.gain.exponentialRampToValueAtTime(0.0001, start + 0.45);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start(start);
      osc.stop(start + 0.5);
      start += 0.18;
    }
  } catch (_) {
    // Son indisponible : l'alerte visuelle suffit.
  }
}
