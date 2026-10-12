import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show RealtimeChannel;

import '../../data/api.dart';
import '../../data/models.dart';
import '../../data/order_models.dart';
import '../../data/orders_api.dart';
import '../../data/reservations_api.dart';
import '../../ui/branch_scope.dart';
import '../../ui/chime.dart';

/// Alerte du service (son + message) : commande client à valider, plat prêt.
enum ServiceAlert { newCustomerOrder, orderReady }

/// Données du service d'un établissement, tenues à jour en direct :
/// salle (zones, tables), commandes en cours, réservations du jour.
class ServiceHub extends ChangeNotifier {
  ServiceHub(this.api, this.scope);

  final Api api;
  final BranchContext scope;

  List<ServiceArea> areas = const [];
  List<Order> orders = const [];
  List<Reservation> reservations = const [];
  List<Reservation> requests = const [];
  Object? error;
  bool loaded = false;

  final _alerts = StreamController<ServiceAlert>.broadcast();
  Stream<ServiceAlert> get alerts => _alerts.stream;

  RealtimeChannel? _channel;
  Timer? _timer;
  Timer? _debounce;
  bool _disposed = false;
  Set<String>? _knownPending;
  Set<String>? _knownReadyLines;

  bool get canReservations => scope.can('reservations.manage');

  Map<String, String> get tableLabels => {
        for (final a in areas)
          for (final tb in a.tables) tb.id: tb.label,
      };

  List<DiningTable> get allTables => [for (final a in areas) ...a.tables];

  int get toValidateCount => orders.where((o) => o.awaitingAcceptance).length;
  int get readyCount => orders.where((o) => o.stage == OrderStage.ready).length;

  void start() {
    load();
    _channel = api.orders.watchService(scope.branchId, _soon);
    // Chronomètres, réservations qui approchent, filet de sécurité si le direct décroche.
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => load());
  }

  void _soon() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), load);
  }

  Future<void> load() async {
    try {
      final today = DateTime.now();
      final r = await Future.wait<dynamic>([
        api.floor(scope.branchId),
        api.orders.board(scope.branchId),
        canReservations ? api.reservations.day(scope.branchId, today) : Future.value(<Reservation>[]),
        canReservations ? api.reservations.requests(scope.branchId) : Future.value(<Reservation>[]),
      ]);
      if (_disposed) return;
      areas = r[0] as List<ServiceArea>;
      orders = r[1] as List<Order>;
      reservations = r[2] as List<Reservation>;
      requests = r[3] as List<Reservation>;
      error = null;
      loaded = true;
      _detectAlerts();
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      error = e;
      notifyListeners();
    }
  }

  void _detectAlerts() {
    final pending = {for (final o in orders.where((o) => o.awaitingAcceptance)) o.id};
    final readyLines = {
      for (final o in orders)
        for (final l in o.lines.where((l) => l.ready)) l.id,
    };
    if (_knownPending != null && pending.difference(_knownPending!).isNotEmpty) {
      playChime(urgent: true);
      _alerts.add(ServiceAlert.newCustomerOrder);
    } else if (_knownReadyLines != null && readyLines.difference(_knownReadyLines!).isNotEmpty) {
      playChime();
      _alerts.add(ServiceAlert.orderReady);
    }
    _knownPending = pending;
    _knownReadyLines = readyLines;
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _debounce?.cancel();
    if (_channel != null) api.orders.unwatch(_channel!);
    _alerts.close();
    super.dispose();
  }
}
