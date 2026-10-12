/// Configuration par environnement, fournie à la compilation :
///   flutter run --dart-define-from-file=env/dev.json
/// Jamais de clé « service_role » ni de secret ici : uniquement l'URL et la
/// clé publique Supabase (protégée par la RLS côté serveur).
class Env {
  static const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'development');
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Adresse publique du site Resto (liens des QR codes et des fiches
  /// restaurants). Par défaut sur le Web : l'adresse courante.
  static const publicUrl = String.fromEnvironment('PUBLIC_URL');

  static bool get configured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static String get siteUrl {
    if (publicUrl.isNotEmpty) return publicUrl.endsWith('/') ? publicUrl.substring(0, publicUrl.length - 1) : publicUrl;
    final base = Uri.base;
    return (base.scheme == 'http' || base.scheme == 'https') ? '${base.scheme}://${base.authority}' : 'https://resto.app';
  }
  static bool get isProduction => appEnv == 'production';

  /// Firebase Cloud Messaging (notifications push) : identifiants publics du
  /// projet Firebase (Paramètres du projet › Vos applications). Vides : les
  /// notifications restent visibles dans l'application, sans push.
  static const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const firebaseSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const firebaseAndroidAppId = String.fromEnvironment('FIREBASE_ANDROID_APP_ID');
  static const firebaseWebAppId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
  static const firebaseWebApiKey = String.fromEnvironment('FIREBASE_WEB_API_KEY');
  static const firebaseAuthDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');

  /// Clé publique « Web Push » (Cloud Messaging › Certificats Web Push).
  static const firebaseVapidKey = String.fromEnvironment('FIREBASE_VAPID_KEY');

  static bool get pushConfigured => firebaseProjectId.isNotEmpty && firebaseSenderId.isNotEmpty;
}
