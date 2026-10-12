import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resto/app_state.dart';
import 'package:resto/core/locales.dart';
import 'package:resto/core/server_errors.dart';
import 'package:resto/data/api.dart';
import 'package:resto/l10n/app_localizations.dart';
import 'package:resto/main.dart';

void main() {
  test('8 langues d\'interface, codes alignés sur public.ref_languages', () {
    final codes = AppLocalizations.supportedLocales.map(refLocaleCode).toSet();
    expect(codes, {'fr', 'en', 'de', 'es', 'pt', 'ar', 'zh-Hans', 'zh-Hant'});
    expect(codes, languageNames.keys.toSet());
    for (final c in codes) {
      expect(refLocaleCode(localeFromRef(c)!), c);
    }
  });

  test('codes d\'erreur serveur traduits, message brut jamais affiché', () async {
    final fr = await AppLocalizations.delegate.load(const Locale('fr'));
    expect(serverErrorText(fr, message: 'resto.last_owner'), fr.errorLastOwner);
    expect(serverErrorText(fr, code: '42501', message: 'new row violates row-level security policy'),
        fr.errorForbidden);
    expect(serverErrorText(fr, code: '23505', message: 'duplicate key'), fr.errorDuplicate);
    expect(serverErrorText(fr, message: 'something else'), fr.errorUnknown);
  });

  test('pluriels arabes', () async {
    final ar = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(ar.pendingSyncEvents(2), 'عمليتان قيد الانتظار');
    expect(ar.tablesCount(2), 'طاولتان');
  });

  test('identifiant public : même règle que app_private.slugify', () {
    expect(slugify('Chez Léa — Akwa'), 'chez-lea-akwa');
    expect(slugify('  Ça & Là !! '), 'ca-la');
    expect(slugify('北京烤鸭'), '');
  });

  testWidgets('sans configuration : écran dédié, passage en arabe de droite à gauche', (tester) async {
    await tester.pumpWidget(RestoApp(state: AppState(null), fonts: false));
    await tester.pumpAndSettle();
    expect(find.byType(ConfigMissingScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.translate));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العربية').last);
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(ConfigMissingScreen));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(find.text('الإعدادات غير مكتملة'), findsOneWidget);
  });
}
