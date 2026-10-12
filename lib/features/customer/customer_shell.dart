import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent, AuthState;

import '../../app_state.dart';
import '../../core/push_service.dart';
import '../../core/money.dart';
import '../../data/customer_api.dart';
import '../../ui/common.dart';
import '../../ui/theme.dart';
import '../auth/auth_screens.dart';
import 'customer_account.dart';
import 'customer_home.dart';
import 'feed_page.dart';
import 'group_order.dart';
import 'loyalty_pages.dart';
import 'restaurant_page.dart';

/// Articles d'un restaurant dans le panier.
class CartGroup {
  CartGroup(this.menu);
  final PublicMenu menu;
  final List<CartLine> lines = [];

  String get branchId => menu.branchId;
  int get count => lines.fold(0, (a, l) => a + l.quantity);
  int total(String channel) => lines.fold(0, (a, l) => a + l.unitPrice(channel) * l.quantity);
}

/// Panier du client : plusieurs restaurants à la fois ; la validation crée une
/// commande indépendante par restaurant.
class CustomerCart extends ChangeNotifier {
  final List<CartGroup> groups = [];

  /// Jeton de table (commande sur place via QR code), pour le restaurant de cette table.
  String? tableToken;
  String? tableLabel;
  String? tableBranchId;

  /// Restaurant → contenu du fil « Découvrir » d'où vient le client (attribution des commandes).
  final Map<String, String> adSource = {};

  /// Panier d'une commande groupée : les plats choisis sont ajoutés à la commande partagée.
  String? groupToken;

  int get count => groups.fold(0, (a, g) => a + g.count);
  bool get isEmpty => groups.every((g) => g.lines.isEmpty);

  /// Toutes les lignes (compatibilité : un seul restaurant).
  List<CartLine> get lines => [for (final g in groups) ...g.lines];

  /// Premier restaurant du panier.
  PublicMenu? get menu => groups.firstOrNull?.menu;

  String channelFor(String branchId) => tableToken != null && tableBranchId == branchId ? 'dine_in' : 'takeaway';

  /// Canal servant à afficher les prix du restaurant consulté.
  String get channelForPrices => tableToken != null ? 'dine_in' : 'takeaway';

  /// Monnaie commune (null si les restaurants n'ont pas la même).
  String? get currency {
    final c = groups.map((g) => g.menu.currency).toSet();
    return c.length == 1 ? c.first : null;
  }

  int total(String channel) => groups.fold(0, (a, g) => a + g.total(channelFor(g.branchId)));

  void add(PublicMenu m, CartLine line) {
    var group = groups.where((g) => g.branchId == m.branchId).firstOrNull;
    if (group == null) {
      group = CartGroup(m);
      groups.add(group);
    }
    final same = group.lines.where(
      (l) =>
          l.variant.id == line.variant.id &&
          l.note == line.note &&
          l.modifiers.map((x) => x.id).toSet().containsAll(line.modifiers.map((x) => x.id)) &&
          l.modifiers.length == line.modifiers.length,
    );
    if (same.isNotEmpty) {
      same.first.quantity += line.quantity;
    } else {
      group.lines.add(line);
    }
    notifyListeners();
  }

  void setQuantity(CartLine l, int q) {
    for (final g in groups) {
      if (!g.lines.contains(l)) continue;
      if (q <= 0) {
        g.lines.remove(l);
      } else {
        l.quantity = q;
      }
    }
    groups.removeWhere((g) => g.lines.isEmpty);
    notifyListeners();
  }

  void removeGroup(String branchId) {
    groups.removeWhere((g) => g.branchId == branchId);
    notifyListeners();
  }

  void clear() {
    groups.clear();
    adSource.clear();
    notifyListeners();
  }
}

/// Accès au panier et à la navigation de l'espace client depuis les écrans enfants.
class CustomerScope extends InheritedNotifier<CustomerCart> {
  const CustomerScope({super.key, required CustomerCart cart, required this.openTab, required super.child}) : super(notifier: cart);
  final ValueChanged<int> openTab;

  static CustomerScope of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<CustomerScope>()!;
  static CustomerCart cart(BuildContext context) => of(context).notifier!;
}

/// Espace client (maquettes « marketplace ») : Accueil, Découvrir, Favoris,
/// Commandes, Profil. On parcourt sans compte ; commander, les favoris et le
/// profil demandent de se connecter.
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key, this.branchId, this.tableToken, this.groupToken});
  final String? branchId;
  final String? tableToken;

  /// Lien de commande groupée (?g=).
  final String? groupToken;

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  final _cart = CustomerCart();
  int _tab = 0;
  StreamSubscription<AuthState>? _auth;
  StreamSubscription<Map<String, dynamic>>? _pushTaps;

  @override
  void initState() {
    super.initState();
    _cart.tableToken = widget.tableToken;
    final api = AppScope.read(context).api!;
    _auth = api.auth.onAuthStateChange.listen((s) {
      if (!mounted) return;
      if (s.event == AuthChangeEvent.signedIn || s.event == AuthChangeEvent.signedOut) setState(() {});
      if (s.event == AuthChangeEvent.signedIn) _birthday();
    });
    _pushTaps = PushService.instance.taps.stream.listen(_openNotification);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openDeepLink();
      _birthday();
      final pending = PushService.instance.pendingTap;
      if (pending != null) {
        PushService.instance.pendingTap = null;
        _openNotification(pending);
      }
    });
  }

  /// Cadeau d'anniversaire des restaurants fréquentés (une fois par an).
  bool _birthdayChecked = false;
  Future<void> _birthday() async {
    final api = AppScope.read(context).api!.customer;
    if (_birthdayChecked || api.user == null) return;
    _birthdayChecked = true;
    try {
      final gifts = await api.claimBirthdayRewards();
      if (gifts.isNotEmpty && mounted) await showBirthdayGifts(context, gifts);
    } catch (_) {}
  }

  /// ?t= (table) ou ?r= (restaurant) : ouvre directement la carte.
  Future<void> _openDeepLink() async {
    final api = AppScope.read(context).api!.customer;
    String? branchId = widget.branchId;
    if (widget.tableToken != null) {
      try {
        final table = await api.table(widget.tableToken!);
        if (table != null) {
          branchId = table['branch_id'] as String?;
          _cart.tableLabel = table['table_label'] as String? ?? table['label'] as String?;
          _cart.tableBranchId = branchId;
        }
      } catch (_) {}
    }
    if (branchId != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerScope(
            cart: _cart,
            openTab: _go,
            child: RestaurantPage(branchId: branchId!),
          ),
        ),
      );
    }
    if (widget.groupToken != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerScope(
            cart: _cart,
            openTab: _go,
            child: GroupOrderScreen(token: widget.groupToken!),
          ),
        ),
      );
    }
  }

  void _go(int i) => setState(() => _tab = i);

  /// Notification touchée (push) : offre → restaurant ; commande, réservation
  /// → Mes commandes ; cadeau → compte.
  void _openNotification(Map<String, dynamic> data) {
    if (!mounted) return;
    final kind = data['kind'] as String? ?? '';
    final branchId = data['branch_id'] as String?;
    if (kind == 'promotion' && branchId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CustomerScope(cart: _cart, openTab: _go, child: RestaurantPage(branchId: branchId))),
      );
    } else if (kind == 'birthday_reward') {
      _go(4);
    } else if (kind.isNotEmpty && !kind.startsWith('staff_')) {
      _go(3);
    }
  }

  @override
  void dispose() {
    _auth?.cancel();
    _pushTaps?.cancel();
    _cart.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final pages = [
      const CustomerHome(),
      CustomerDiscover(visible: _tab == 1),
      const CustomerFavorites(),
      const CustomerOrders(),
      const CustomerProfilePage(),
    ];
    return CustomerScope(
      cart: _cart,
      openTab: _go,
      child: Scaffold(
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(index: _tab, children: pages),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: ListenableBuilder(
          listenable: _cart,
          builder: (context, _) => _cart.isEmpty ? const SizedBox.shrink() : CartBar(cart: _cart),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            height: 68,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: RestoColors.softShadow(10)),
            child: Row(
              children: [
                for (final (i, icon, label) in [
                  (0, Icons.home_rounded, t.customerHome),
                  (1, Icons.play_circle_outline_rounded, t.customerDiscover),
                  (2, Icons.favorite_border_rounded, t.customerFavorites),
                  (3, Icons.shopping_bag_outlined, t.customerOrders),
                  (4, Icons.person_outline_rounded, t.customerProfile),
                ])
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _go(i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, color: _tab == i ? RestoColors.primaryDeep : RestoColors.muted),
                          const SizedBox(height: 2),
                          FittedBox(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: _tab == i ? FontWeight.w700 : FontWeight.w500,
                                color: _tab == i ? RestoColors.primaryDeep : RestoColors.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Barre flottante du panier (maquette) : icône dorée, « Votre panier »,
/// nombre d'articles et total, bouton « Commander ».
class CartBar extends StatelessWidget {
  const CartBar({super.key, required this.cart});
  final CustomerCart cart;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final currency = cart.currency;
    final locale = Localizations.localeOf(context).toString();
    void open() => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerScope(cart: cart, openTab: CustomerScope.of(context).openTab, child: const CartScreen()),
      ),
    );
    final detail = [
      t.cartItems(cart.count),
      if (cart.groups.length > 1) t.restaurantsCount(cart.groups.length),
      if (currency != null) Money(cart.total(''), currency).format(locale, minorUnitOf(currency)),
    ].join(' • ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 72),
      child: GestureDetector(
        onTap: open,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 560),
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E9D8),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: RestoColors.primary.withValues(alpha: 0.35)),
            boxShadow: RestoColors.softShadow(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(gradient: RestoColors.brandGradient, shape: BoxShape.circle),
                child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(t.yourCart, style: serifTitle(context, size: 19)),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: RestoColors.muted, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                decoration: BoxDecoration(
                  gradient: RestoColors.brandGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: RestoColors.primary.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 5))],
                ),
                child: Text(
                  t.feedOrder,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Décimales d'une monnaie (ISO 4217) sans requête : la plupart en ont 2.
int minorUnitOf(String currency) =>
    const {
      'XAF': 0,
      'XOF': 0,
      'JPY': 0,
      'KRW': 0,
      'CLP': 0,
      'GNF': 0,
      'RWF': 0,
      'UGX': 0,
      'VND': 0,
      'KMF': 0,
      'DJF': 0,
      'BIF': 0,
      'PYG': 0,
      'XPF': 0,
      'ISK': 0,
      'BHD': 3,
      'KWD': 3,
      'OMR': 3,
      'TND': 3,
      'JOD': 3,
      'IQD': 3,
      'LYD': 3,
    }[currency] ??
    2;

/// Demande la connexion (ou l'inscription) du client ; revient une fois connecté.
Future<bool> ensureCustomerSignedIn(BuildContext context) async {
  final api = AppScope.read(context).api!;
  if (api.user != null) return true;
  final ok = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      settings: const RouteSettings(name: _signInRoute),
      builder: (_) => const _CustomerSignIn(),
    ),
  );
  return ok == true || api.user != null;
}

const _signInRoute = 'customer-sign-in';

class _CustomerSignIn extends StatefulWidget {
  const _CustomerSignIn();

  @override
  State<_CustomerSignIn> createState() => _CustomerSignInState();
}

class _CustomerSignInState extends State<_CustomerSignIn> {
  StreamSubscription<AuthState>? _sub;

  @override
  void initState() {
    super.initState();
    final state = AppScope.read(context);
    _sub = state.api!.auth.onAuthStateChange.listen((s) {
      if (s.event == AuthChangeEvent.signedIn && mounted) {
        // Compte entreprise connecté depuis l'espace client : il retrouve son restaurant.
        if (state.api!.accountType == 'business') {
          state.setCustomerMode(false);
          return;
        }
        final nav = Navigator.of(context);
        nav.popUntil((r) => r.settings.name == _signInRoute || r.isFirst);
        if (nav.canPop()) nav.pop(true);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SignInScreen();
}
