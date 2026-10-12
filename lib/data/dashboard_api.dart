import 'package:supabase_flutter/supabase_flutter.dart';

int _int(Object? v) => (v as num? ?? 0).toInt();

/// Tableau de bord d'un établissement sur une période (accueil, rapports).
/// Les montants ne sont fournis qu'avec le droit « finance.read ».
class Dashboard {
  Dashboard.fromJson(Map<String, dynamic> j)
      : currency = j['currency'] as String? ?? '',
        finance = j['finance'] as bool? ?? false,
        openOrders = _int(j['open_orders']),
        pendingOrders = _int(j['pending_orders']),
        ordersCount = _int(j['orders_count']),
        tablesTotal = _int(j['tables_total']),
        tablesBusy = _int(j['tables_busy']),
        lowStock = [
          for (final s in (j['low_stock'] as List? ?? const []))
            ((s as Map)['name'] as String, _int(s['stock'])),
        ],
        sales = j['sales'] == null ? null : _int(j['sales']),
        prevSales = j['prev_sales'] == null ? null : _int(j['prev_sales']),
        ordersClosed = _int(j['orders_closed']),
        byDay = [
          for (final d in (j['by_day'] as List? ?? const []))
            (DateTime.parse((d as Map)['day'] as String), _int(d['total'])),
        ],
        byHour = {for (final h in (j['by_hour'] as List? ?? const [])) _int((h as Map)['hour']): _int(h['total'])},
        topItems = [
          for (final t in (j['top_items'] as List? ?? const []))
            TopItem((t as Map)['name'] as String, _int(t['quantity']), _int(t['total'])),
        ],
        byChannel = {
          for (final c in (j['by_channel'] as List? ?? const [])) (c as Map)['channel'] as String: (_int(c['total']), _int(c['count'])),
        },
        recent = [
          for (final r in (j['recent'] as List? ?? const [])) RecentPayment.fromJson((r as Map).cast<String, dynamic>()),
        ];

  final String currency;
  final bool finance;
  final int openOrders;
  final int pendingOrders;
  final int ordersCount;
  final int tablesTotal;
  final int tablesBusy;

  /// (article, quantité restante) sous le seuil d'alerte.
  final List<(String, int)> lowStock;
  final int? sales;
  final int? prevSales;
  final int ordersClosed;
  final List<(DateTime, int)> byDay;
  final Map<int, int> byHour;
  final List<TopItem> topItems;

  /// canal → (chiffre d'affaires, nombre de commandes).
  final Map<String, (int, int)> byChannel;
  final List<RecentPayment> recent;

  int get averageTicket => (sales == null || ordersClosed == 0) ? 0 : (sales! / ordersClosed).round();

  /// Taux d'occupation des tables (0–100).
  int get occupancy => tablesTotal == 0 ? 0 : (tablesBusy * 100 / tablesTotal).round();

  /// Évolution du chiffre d'affaires par rapport à la période précédente (%), null si incalculable.
  double? get salesTrend {
    if (sales == null || prevSales == null || prevSales == 0) return null;
    return (sales! - prevSales!) * 100 / prevSales!;
  }
}

class TopItem {
  const TopItem(this.name, this.quantity, this.total);
  final String name;
  final int quantity;
  final int total;
}

class RecentPayment {
  RecentPayment.fromJson(Map<String, dynamic> j)
      : at = DateTime.parse(j['at'] as String),
        orderNumber = _int(j['order_number']),
        customer = j['customer'] as String?,
        channel = j['channel'] as String? ?? 'dine_in',
        amount = _int(j['amount']),
        method = j['method'] as String? ?? '',
        orderStatus = j['order_status'] as String? ?? 'open';
  final DateTime at;
  final int orderNumber;
  final String? customer;
  final String channel;
  final int amount;
  final String method;
  final String orderStatus;
}

class DashboardApi {
  DashboardApi(this._db);
  final SupabaseClient _db;

  static String _day(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<Dashboard> load(String branchId, DateTime from, DateTime to) async => Dashboard.fromJson(
        ((await _db.rpc('branch_dashboard', params: {'p_branch': branchId, 'p_from': _day(from), 'p_to': _day(to)})) as Map)
            .cast<String, dynamic>(),
      );
}
