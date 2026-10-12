import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import '../data/supabase_setup.dart';
import '../l10n/app_localizations.dart';
import 'server_errors.dart';

/// Message lisible pour n'importe quelle erreur (base, authentification,
/// réseau). Le texte technique n'est jamais affiché à l'utilisateur.
String errorText(AppLocalizations t, Object e) {
  if (e is PostgrestException) {
    final text = serverErrorText(t, code: e.code, message: e.message);
    return text == t.errorUnknown ? _unknown(t, e) : text;
  }
  if (e is AuthException) {
    // Une erreur 5xx est aussi « retryable » : réseau seulement sans code HTTP.
    if (e is AuthRetryableFetchException && e.statusCode == null) return t.errorNetwork;
    switch (e.code) {
      case 'invalid_credentials':
        return t.authInvalidCredentials;
      case 'email_not_confirmed':
        return t.authEmailNotConfirmed;
      case 'user_already_exists':
      case 'email_exists':
        return t.authUserExists;
      case 'weak_password':
        return t.authWeakPassword;
      case 'otp_expired':
      case 'otp_disabled':
        return t.authCodeInvalid;
      case 'same_password':
        return t.authSamePassword;
      case 'over_email_send_rate_limit':
      case 'over_request_rate_limit':
        return t.errorRateLimited;
    }
    return _unknown(t, e);
  }
  if (e is StorageException) {
    // Envoi de fichier refusé par le stockage : taille, format ou droits.
    final m = e.message.toLowerCase();
    if (e.statusCode == '413' || m.contains('exceeded') || m.contains('too large')) return t.errorFileTooLarge;
    if (e.statusCode == '415' || m.contains('mime')) return t.errorFileType;
    if (e.statusCode == '403' || e.statusCode == '401' || m.contains('row-level security') || m.contains('unauthorized')) {
      return t.errorForbidden;
    }
  }
  if (isConnectError(e)) return t.errorNetwork;
  return _unknown(t, e);
}

/// Erreur imprévue : hors production, le détail technique est ajouté pour le
/// diagnostic (jamais en production).
String _unknown(AppLocalizations t, Object e) {
  if (Env.isProduction) return t.errorUnknown;
  final detail = e.toString().replaceAll(RegExp(r'\s+'), ' ');
  return '${t.errorUnknown}\n${detail.length > 220 ? '${detail.substring(0, 220)}…' : detail}';
}
