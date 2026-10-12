import 'dart:convert';
import 'dart:io';

/// Génère web/firebase-messaging-sw.js (notifications web reçues quand l'onglet
/// est fermé) à partir des identifiants publics Firebase du fichier env :
///   dart run tool/gen_firebase_sw.dart env/dev.json
/// À relancer avant chaque « flutter build web » si la configuration change.
void main(List<String> args) {
  final env = (jsonDecode(File(args.isEmpty ? 'env/dev.json' : args.first).readAsStringSync()) as Map).cast<String, dynamic>();
  String v(String k) => (env[k] as String? ?? '').trim();
  final out = File('web/firebase-messaging-sw.js');
  if (v('FIREBASE_PROJECT_ID').isEmpty || v('FIREBASE_WEB_APP_ID').isEmpty) {
    out.writeAsStringSync('// Notifications web non configurées (identifiants Firebase absents).\n');
    stdout.writeln('Firebase non configuré : service vide.');
    return;
  }
  final config = jsonEncode({
    'apiKey': v('FIREBASE_WEB_API_KEY').isNotEmpty ? v('FIREBASE_WEB_API_KEY') : v('FIREBASE_API_KEY'),
    'authDomain': v('FIREBASE_AUTH_DOMAIN'),
    'projectId': v('FIREBASE_PROJECT_ID'),
    'messagingSenderId': v('FIREBASE_MESSAGING_SENDER_ID'),
    'appId': v('FIREBASE_WEB_APP_ID'),
  });
  out.writeAsStringSync('''
// Généré par tool/gen_firebase_sw.dart — ne pas modifier à la main.
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');
firebase.initializeApp($config);
const messaging = firebase.messaging();
// Notification touchée : ouvre (ou ramène) l'application.
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(clients.matchAll({ type: 'window', includeUncontrolled: true }).then((list) => {
    for (const c of list) { if ('focus' in c) return c.focus(); }
    return clients.openWindow('/');
  }));
});
''');
  stdout.writeln('web/firebase-messaging-sw.js généré.');
}
