import 'package:flutter/widgets.dart';

import 'core/locales.dart';
import 'data/api.dart';
import 'data/models.dart';
import 'data/supabase_setup.dart' show writeCustomerSpace;

/// État partagé de l'application : langue, adhésions, organisation courante.
class AppState extends ChangeNotifier {
  AppState(this.api);

  /// null si l'application n'est pas configurée (pas d'URL / clé publique).
  final Api? api;

  /// null = langue de l'appareil.
  Locale? locale;
  List<Membership> memberships = const [];

  /// Aperçu de la mise en page (développement) : pas de session.
  bool previewLayout = false;

  /// Espace client affiché (vitrine, commande, profil) au lieu de l'espace restaurant.
  bool customerMode = false;

  /// Change d'espace ; le choix est retenu pour la prochaine ouverture.
  void setCustomerMode(bool on) {
    customerMode = on;
    writeCustomerSpace(on);
    notifyListeners();
  }
  String? _currentOrgId;
  Future<References>? _references;

  Membership? get current {
    for (final m in memberships) {
      if (m.organizationId == _currentOrgId) return m;
    }
    return memberships.isEmpty ? null : memberships.first;
  }

  Future<void> refreshMemberships() async {
    memberships = await api!.myMemberships();
    if (current != null) _currentOrgId = current!.organizationId;
    notifyListeners();
  }

  void selectOrganization(String orgId) {
    _currentOrgId = orgId;
    notifyListeners();
  }

  /// Référentiels chargés une fois (pays, monnaies, fuseaux).
  Future<References> references() => _references ??= api!.references().catchError((Object e) {
        _references = null;
        throw e;
      });

  /// Change la langue ; connecté, elle est aussi enregistrée dans le profil.
  Future<void> setLocale(Locale? value) async {
    locale = value;
    notifyListeners();
    if (value != null && api?.user != null) await api!.saveLocale(refLocaleCode(value));
  }

  /// À la connexion : reprend la langue enregistrée dans le profil.
  Future<void> loadProfileLocale() async {
    final profile = await api!.myProfile();
    final saved = localeFromRef(profile?['locale'] as String?);
    if (saved != null && saved != locale) {
      locale = saved;
      notifyListeners();
    }
  }

  void clearSession() {
    memberships = const [];
    _currentOrgId = null;
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Sans abonnement aux changements (dans les gestionnaires d'évènements).
  static AppState read(BuildContext context) => context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

/// Membre fictif de l'aperçu de mise en page (tous les droits, aucune donnée).
Membership previewMembership() => Membership(
      id: '00000000-0000-0000-0000-000000000000',
      organizationId: '00000000-0000-0000-0000-000000000000',
      organizationName: 'Le Grand Cru',
      organizationStatus: 'active',
      role: 'owner',
      allBranches: true,
      branchIds: const [],
      permissions: const {
        'org.manage', 'members.manage', 'audit.read', 'branches.manage', 'menus.manage', 'orders.read', 'orders.write',
        'orders.void', 'kitchen.operate', 'reservations.manage', 'cash.operate', 'cash.close', 'payments.refund',
        'stock.read', 'stock.write', 'stock.adjust', 'purchases.manage', 'expenses.manage', 'finance.read', 'customers.manage',
        'marketing.manage',
      },
    );
