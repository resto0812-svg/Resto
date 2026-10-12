import 'package:supabase_flutter/supabase_flutter.dart';

/// Préférences du membre connecté pour une organisation (notifications, sons).
class MemberPrefs {
  MemberPrefs(this.values);
  final Map<String, dynamic> values;

  bool flag(String key, {bool fallback = true}) => values[key] as bool? ?? fallback;
  void set(String key, Object? value) => values[key] = value;

  /// Réglages proposés dans Paramètres › Notifications.
  static const flags = [
    'sound_new_order', // son à chaque nouvelle commande (salle, QR, en ligne)
    'sound_ready', // son quand une commande est prête à servir
    'alert_late', // alerte des commandes en retard
    'alert_low_stock', // alerte de stock faible sur l'accueil
    'alert_reservations', // rappel des réservations de l'heure
    'alert_cash_gap', // écart de caisse à la clôture
    'push_new_order', // notification (téléphone, navigateur) : nouvelle commande d'un client
    'push_order_ready', // notification : commande prête à servir
    'push_reservations', // notification : nouvelle demande de réservation
    'push_reviews', // notification : nouvel avis sur un plat
  ];
}

class PrefsApi {
  PrefsApi(this._db);
  final SupabaseClient _db;

  Future<MemberPrefs> load(String orgId) async {
    final row = await _db.from('member_preferences').select('prefs').eq('organization_id', orgId).maybeSingle();
    return MemberPrefs(((row?['prefs'] as Map?) ?? const {}).cast<String, dynamic>());
  }

  Future<void> save(String orgId, MemberPrefs prefs) => _db.from('member_preferences').upsert(
        {'user_id': _db.auth.currentUser!.id, 'organization_id': orgId, 'prefs': prefs.values},
        onConflict: 'user_id,organization_id',
      );
}
