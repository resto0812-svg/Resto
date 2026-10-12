import 'package:flutter/services.dart';

/// Hors Web : son système et vibration.
void playChime({bool urgent = false}) {
  SystemSound.play(SystemSoundType.alert);
  if (urgent) HapticFeedback.heavyImpact();
}
