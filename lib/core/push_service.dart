import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../config/env.dart';
import '../data/api.dart';

/// Notifications push (Firebase Cloud Messaging), sur le téléphone et sur le
/// web. Le serveur décide quoi envoyer et à qui (migration 031) ; ici on
/// enregistre l'appareil du compte connecté, on affiche les messages reçus
/// pendant que l'application est ouverte et on transmet les appuis.
/// Sans configuration Firebase, rien ne se passe : les notifications restent
/// visibles dans l'application (cloche).
class PushService {
  PushService._();
  static final instance = PushService._();

  static const _channel = AndroidNotificationChannel(
    'resto_default',
    'Resto',
    description: 'Commandes, réservations, avis et offres',
    importance: Importance.high,
  );

  final _local = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  String? _token;
  StreamSubscription<String>? _refresh;

  /// Notification touchée (type et identifiants : order_id, branch_id…).
  final taps = StreamController<Map<String, dynamic>>.broadcast();

  /// Notification qui a ouvert l'application ; lue une fois par l'écran d'accueil.
  Map<String, dynamic>? pendingTap;

  static FirebaseOptions get _options => FirebaseOptions(
        apiKey: kIsWeb && Env.firebaseWebApiKey.isNotEmpty ? Env.firebaseWebApiKey : Env.firebaseApiKey,
        appId: kIsWeb ? Env.firebaseWebAppId : Env.firebaseAndroidAppId,
        messagingSenderId: Env.firebaseSenderId,
        projectId: Env.firebaseProjectId,
        authDomain: kIsWeb && Env.firebaseAuthDomain.isNotEmpty ? Env.firebaseAuthDomain : null,
      );

  /// Firebase est configuré pour cette plateforme.
  static bool get firebaseConfigured =>
      Env.pushConfigured && (kIsWeb ? Env.firebaseWebAppId.isNotEmpty : Env.firebaseAndroidAppId.isNotEmpty);

  /// Initialise Firebase une seule fois (notifications, suivi des plantages).
  static Future<void> ensureFirebase() async {
    if (Firebase.apps.isEmpty) await Firebase.initializeApp(options: _options);
  }

  Future<bool> _init() async {
    if (_ready) return true;
    if (!firebaseConfigured) return false;
    try {
      await ensureFirebase();
      if (!kIsWeb) {
        await _local.initialize(
          const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
          onDidReceiveNotificationResponse: (r) {
            if (r.payload != null) taps.add((jsonDecode(r.payload!) as Map).cast<String, dynamic>());
          },
        );
        await _local
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_channel);
      }
      FirebaseMessaging.onMessage.listen(_foreground);
      FirebaseMessaging.onMessageOpenedApp.listen((m) => taps.add(m.data));
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) pendingTap = initial.data;
      _ready = true;
    } catch (e) {
      debugPrint('push: $e');
    }
    return _ready;
  }

  /// Après la connexion : autorisation, jeton, enregistrement de l'appareil.
  Future<void> register(Api api, String locale) async {
    if (!await _init()) return;
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      if (!kIsWeb) {
        await _local
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }
      final token = await FirebaseMessaging.instance
          .getToken(vapidKey: kIsWeb && Env.firebaseVapidKey.isNotEmpty ? Env.firebaseVapidKey : null);
      if (token == null) return;
      _token = token;
      await api.registerPushDevice(token, kIsWeb ? 'web' : 'android', locale);
      _refresh ??= FirebaseMessaging.instance.onTokenRefresh.listen((t) {
        _token = t;
        api.registerPushDevice(t, kIsWeb ? 'web' : 'android', locale).catchError((Object _) {});
      });
    } catch (e) {
      debugPrint('push: $e');
    }
  }

  /// Avant la déconnexion : l'appareil ne reçoit plus les notifications du compte.
  Future<void> unregister(Api api) async {
    final token = _token;
    if (token == null) return;
    _token = null;
    try {
      await api.unregisterPushDevice(token);
    } catch (_) {}
  }

  /// Application ouverte : Android n'affiche pas la notification de lui-même.
  void _foreground(RemoteMessage m) {
    final n = m.notification;
    if (n == null || kIsWeb) return;
    _local.show(
      m.messageId.hashCode & 0x3fffffff,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(_channel.id, _channel.name,
            channelDescription: _channel.description, importance: Importance.high, priority: Priority.high),
      ),
      payload: jsonEncode(m.data),
    );
  }
}
