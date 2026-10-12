import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

const _storage = FlutterSecureStorage();

/// Session Supabase (jetons) dans le stockage chiffré du système
/// (Keystore / Keychain ; chiffré par WebCrypto sur le Web), jamais en clair.
class SecureSessionStorage extends LocalStorage {
  const SecureSessionStorage();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() => _storage.containsKey(key: supabasePersistSessionKey);

  @override
  Future<String?> accessToken() => _storage.read(key: supabasePersistSessionKey);

  @override
  Future<void> removePersistedSession() => _storage.delete(key: supabasePersistSessionKey);

  @override
  Future<void> persistSession(String persistSessionString) => _storage.write(key: supabasePersistSessionKey, value: persistSessionString);
}

/// Code PKCE du flux d'authentification, lui aussi en stockage chiffré.
class SecurePkceStorage extends GotrueAsyncStorage {
  const SecurePkceStorage();

  @override
  Future<String?> getItem({required String key}) => _storage.read(key: key);

  @override
  Future<void> setItem({required String key, required String value}) => _storage.write(key: key, value: value);

  @override
  Future<void> removeItem({required String key}) => _storage.delete(key: key);
}

/// Espace retenu entre deux ouvertures (client ou restaurant) : aucune donnée personnelle.
const _spaceKey = 'resto.space';

Future<bool> readCustomerSpace() async {
  try {
    return await _storage.read(key: _spaceKey) == 'client';
  } catch (_) {
    return false;
  }
}

Future<void> writeCustomerSpace(bool on) async {
  try {
    await _storage.write(key: _spaceKey, value: on ? 'client' : 'restaurant');
  } catch (_) {}
}

/// Erreur survenue AVANT que la requête n'atteigne le serveur : un nouvel
/// essai ne peut donc rien enregistrer deux fois.
bool isConnectError(Object e) {
  final s = e.toString();
  return s.contains('HandshakeException') ||
      s.contains('Failed host lookup') ||
      s.contains('Connection refused') ||
      s.contains('Connection timed out') ||
      s.contains('Network is unreachable') ||
      s.contains('XMLHttpRequest error') ||
      s.contains('ClientException');
}

/// Jusqu'à 3 nouveaux essais (0,4 s, 1 s, 2,5 s) sur une coupure passagère.
http.Client resilientHttpClient() => RetryClient(
  http.Client(),
  retries: 3,
  when: (_) => false,
  whenError: (e, _) => isConnectError(e),
  delay: (n) => const [Duration(milliseconds: 400), Duration(seconds: 1), Duration(milliseconds: 2500)][n.clamp(0, 2)],
);

Future<void> initSupabase() => Supabase.initialize(
  url: Env.supabaseUrl,
  // Clé publique (sb_publishable_… ou anon), jamais la service_role.
  publishableKey: Env.supabaseAnonKey,
  httpClient: resilientHttpClient(),
  authOptions: const FlutterAuthClientOptions(localStorage: SecureSessionStorage(), pkceAsyncStorage: SecurePkceStorage()),
  debug: kDebugMode && !Env.isProduction,
);

/// Imprimante de tickets de cet appareil : largeur du rouleau (80 ou 58 mm)
/// et photos des plats. Réglage local : chaque caisse a sa propre imprimante.
const _paperKey = 'resto.ticket.paper';
const _photosKey = 'resto.ticket.photos';

Future<(int, bool)> readTicketPrefs() async {
  try {
    final r = await Future.wait([_storage.read(key: _paperKey), _storage.read(key: _photosKey)]);
    return (r[0] == '58' ? 58 : 80, r[1] != '0');
  } catch (_) {
    return (80, true);
  }
}

Future<void> writeTicketPrefs(int paperMm, bool photos) async {
  try {
    await _storage.write(key: _paperKey, value: '$paperMm');
    await _storage.write(key: _photosKey, value: photos ? '1' : '0');
  } catch (_) {}
}

/// Identifiant anonyme de cet appareil pour les vues sans compte (aléatoire,
/// créé une fois, sans lien avec la personne).
const _viewerKeyName = 'resto.viewer';

Future<String> readViewerKey() async {
  try {
    final saved = await _storage.read(key: _viewerKeyName);
    if (saved != null && saved.length >= 8) return saved;
  } catch (_) {}
  final r = Random.secure();
  final key = 'v-${List.generate(24, (_) => r.nextInt(36).toRadixString(36)).join()}';
  try {
    await _storage.write(key: _viewerKeyName, value: key);
  } catch (_) {}
  return key;
}