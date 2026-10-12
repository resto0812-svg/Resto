import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'push_service.dart';

/// Suivi des plantages (Firebase Crashlytics, téléphone uniquement) : chaque
/// erreur imprévue est remontée dans la console Firebase avec la version de
/// l'application. Aucune donnée personnelle n'est jointe (ni nom, ni e-mail).
Future<void> initCrashReporting() async {
  if (kIsWeb || !PushService.firebaseConfigured) return;
  try {
    await PushService.ensureFirebase();
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack);
      return true;
    };
  } catch (e) {
    debugPrint('crashlytics: $e');
  }
}