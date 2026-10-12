import 'dart:ui';

/// Codes de langue de la base (public.ref_languages, BCP 47) ↔ langues de
/// l'interface Flutter. Le chinois simplifié est la variante « zh » de base.
String refLocaleCode(Locale l) {
  if (l.languageCode != 'zh') return l.languageCode;
  return l.scriptCode == 'Hant' ? 'zh-Hant' : 'zh-Hans';
}

Locale? localeFromRef(String? code) => switch (code) {
      null || '' => null,
      'zh-Hans' => const Locale('zh'),
      'zh-Hant' => const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      final c => Locale(c),
    };

/// Noms natifs des langues (identiques à public.ref_languages).
const languageNames = <String, String>{
  'fr': 'Français',
  'en': 'English',
  'de': 'Deutsch',
  'es': 'Español',
  'pt': 'Português',
  'ar': 'العربية',
  'zh-Hans': '简体中文',
  'zh-Hant': '繁體中文',
};
