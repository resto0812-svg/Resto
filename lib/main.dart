import 'dart:async';

import 'package:flutter/foundation.dart' show LicenseEntryWithLineBreaks, LicenseRegistry;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_state.dart';
import 'config/env.dart';
import 'core/crash_reporting.dart';
import 'core/push_service.dart';
import 'data/api.dart';
import 'data/supabase_setup.dart';
import 'features/auth/auth_screens.dart';
import 'features/customer/customer_shell.dart';
import 'features/org/home_shell.dart';
import 'features/org/onboarding_screen.dart';
import 'l10n/app_localizations.dart';
import 'ui/common.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Licence des polices intégrées (SIL Open Font License), visible dans « Licences ».
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(['google_fonts'], await rootBundle.loadString('assets/google_fonts/OFL.txt'));
  });
  // Barres du système sur fond ivoire : icônes foncées.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: RestoColors.base,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  await initCrashReporting();
  Api? api;
  if (Env.configured) {
    await initSupabase();
    api = Api(Supabase.instance.client);
  }
  final state = AppState(api);
  // Aperçu de la mise en page sans connexion (développement uniquement, jamais
  // en production) : ?apercu=navigation. Aucune donnée : la RLS refuse tout.
  if (api != null && !Env.isProduction && Uri.base.queryParameters['apercu'] == 'navigation') {
    state.previewLayout = true;
    state.memberships = [previewMembership()];
  }
  // Liens de l'espace client : page d'un restaurant (?r=), QR d'une table (?t=), commande groupée (?g=),
  // vitrine (?espace=client).
  final q = Uri.base.queryParameters;
  if (q.containsKey('r') || q.containsKey('t') || q.containsKey('g') || q['espace'] == 'client') {
    state.customerMode = true;
  } else if (api != null && !state.previewLayout) {
    // Dernier espace utilisé (un client retrouve l'espace client à la réouverture).
    state.customerMode = await readCustomerSpace();
  }
  // Notifications push : l'appareil est enregistré pour le compte connecté.
  final pushApi = api;
  if (pushApi != null && !state.previewLayout) {
    pushApi.auth.onAuthStateChange.listen((s) {
      if (s.session != null && (s.event == AuthChangeEvent.signedIn || s.event == AuthChangeEvent.initialSession)) {
        final locale = state.locale ?? WidgetsBinding.instance.platformDispatcher.locale;
        PushService.instance.register(pushApi, locale.languageCode);
      }
    });
  }
  runApp(RestoApp(state: state));
}

class RestoApp extends StatelessWidget {
  const RestoApp({super.key, required this.state, this.fonts = true});
  final AppState state;

  /// Polices de la marque (désactivées dans les tests).
  final bool fonts;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) => MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appName,
          debugShowCheckedModeBanner: false,
          locale: state.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: restoTheme(Brightness.light, fonts: fonts),
          // Toujours le thème ivoire des maquettes, comme sur le web, même si le
          // téléphone est en mode sombre.
          themeMode: ThemeMode.light,
          builder: (context, child) => _EnvironmentBanner(child: child!),
          home: state.api == null
              ? const ConfigMissingScreen()
              : state.previewLayout
                  ? const HomeShell()
                  : state.customerMode
                      ? CustomerShell(
                          branchId: Uri.base.queryParameters['r'],
                          tableToken: Uri.base.queryParameters['t'],
                          groupToken: Uri.base.queryParameters['g'],
                        )
                      : const AuthGate(),
        ),
      ),
    );
  }
}

/// Bandeau visible hors production, pour ne jamais confondre les données de
/// test avec les données réelles.
class _EnvironmentBanner extends StatelessWidget {
  const _EnvironmentBanner({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!Env.showEnvBanner) return child;
    return Column(children: [
      Material(
        color: RestoColors.primary,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(context.t.environmentBanner(Env.appEnv),
                  textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
      Expanded(child: MediaQuery.removePadding(context: context, removeTop: true, child: child)),
    ]);
  }
}

class ConfigMissingScreen extends StatelessWidget {
  const ConfigMissingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(title: Text(t.appName), actions: const [LanguageMenuButton()]),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(t.configMissingTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(t.configMissingBody, textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}

/// Connecté → organisations ; sinon → connexion.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AppState _state = AppScope.read(context);
  late Session? _session = _state.api!.auth.currentSession;
  StreamSubscription<AuthState>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = _state.api!.auth.onAuthStateChange.listen((s) {
      if (s.event == AuthChangeEvent.signedOut) _state.clearSession();
      if (s.event == AuthChangeEvent.signedIn) _state.loadProfileLocale().catchError((Object _) {});
      if (mounted && s.session?.user.id != _session?.user.id) setState(() => _session = s.session);
    });
    if (_session != null) _state.loadProfileLocale().catchError((Object _) {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_session == null) return const SignInScreen();
    return OrganizationGate(key: ValueKey(_session!.user.id));
  }
}

/// Aiguillage selon le type de compte choisi à l'inscription :
/// client → espace client ; entreprise → créer / rejoindre un restaurant, puis
/// structure principale. Compte ancien sans type : membre d'un restaurant →
/// entreprise, sinon on demande une fois.
class OrganizationGate extends StatelessWidget {
  const OrganizationGate({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final type = state.api!.accountType;
    if (type == 'customer') {
      WidgetsBinding.instance.addPostFrameCallback((_) => state.setCustomerMode(true));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Loader<void>(
      load: state.refreshMemberships,
      builder: (context, _, _) {
        if (state.memberships.isNotEmpty) {
          if (type == null) state.api!.setAccountType('business').catchError((Object _) {});
          return const HomeShell();
        }
        return type == 'business' ? const OnboardingScreen() : const AccountTypeScreen();
      },
    );
  }
}
