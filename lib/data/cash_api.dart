import 'package:supabase_flutter/supabase_flutter.dart';

/// Caisse : lectures sous RLS (cash.operate ou finance.read), écritures par
/// les fonctions du serveur (open_cash_session, take_payment…).

DateTime? _date(Object? v) => v == null ? null : DateTime.parse(v as String).toLocal();
int _int(Object? v) => (v as num? ?? 0).toInt();

class CashRegister {
  CashRegister(this.id, this.branchId, this.name, this.active);
  final String id;
  final String branchId;
  final String name;
  final bool active;
}

/// Mode de paiement de l'organisation (nommé et réglé par elle).
class PaymentMethod {
  PaymentMethod.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        refCode = j['ref_code'] as String?,
        name = j['name'] as String,
        kind = j['kind'] as String,
        requiresReference = j['requires_reference'] as bool? ?? false,
        feePercent = (j['fee_percent'] as num? ?? 0).toDouble(),
        branchIds = ((j['branch_ids'] as List?) ?? const []).cast<String>(),
        active = j['active'] as bool? ?? true,
        sortOrder = _int(j['sort_order']);
  final String id;
  final String? refCode;
  final String name;

  /// cash, card, mobile_wallet, instant_transfer, bank_transfer, voucher, cheque, customer_account, other.
  final String kind;
  final bool requiresReference;
  final double feePercent;

  /// Vide = tous les établissements.
  final List<String> branchIds;
  final bool active;
  final int sortOrder;

  bool get isCash => kind == 'cash';
  bool availableIn(String branchId) => active && (branchIds.isEmpty || branchIds.contains(branchId));
}

/// Mode du catalogue mondial (suggestions selon le pays).
class RefPaymentMethod {
  RefPaymentMethod.fromJson(Map<String, dynamic> j)
      : code = j['code'] as String,
        kind = j['kind'] as String,
        name = j['name'] as String,
        names = (j['names'] as Map?)?.cast<String, dynamic>() ?? const {},
        countries = ((j['countries'] as List?) ?? const []).cast<String>(),
        requiresReference = j['requires_reference'] as bool? ?? false,
        sortOrder = _int(j['sort_order']);
  final String code;
  final String kind;
  final String name;
  final Map<String, dynamic> names;
  final List<String> countries;
  final bool requiresReference;
  final int sortOrder;

  String label(String locale) => (names[locale] as String?) ?? name;
  bool worldwide() => countries.isEmpty;
  bool commonIn(String country) => countries.contains(country);
}

class Denomination {
  Denomination(this.valueMinor, this.isNote);
  final int valueMinor;
  final bool isNote;
}

class CashSession {
  CashSession.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        registerId = j['register_id'] as String,
        branchId = j['branch_id'] as String,
        currency = j['currency'] as String,
        status = j['status'] as String,
        openingFloatMinor = _int(j['opening_float_minor']),
        openedAt = _date(j['opened_at'])!,
        openedBy = j['opened_by'] as String?,
        expectedCashMinor = (j['expected_cash_minor'] as num?)?.toInt(),
        countedCashMinor = (j['counted_cash_minor'] as num?)?.toInt(),
        differenceMinor = (j['difference_minor'] as num?)?.toInt(),
        countNote = j['count_note'] as String?,
        countedAt = _date(j['counted_at']),
        countedBy = j['counted_by'] as String?,
        validatedAt = _date(j['validated_at']),
        validatedBy = j['validated_by'] as String?,
        validationNote = j['validation_note'] as String?,
        zNumber = (j['z_number'] as num?)?.toInt(),
        openingDetail = _detail(j['opening_detail']),
        countDetail = _detail(j['count_detail']);

  final String id;
  final String registerId;
  final String branchId;
  final String currency;

  /// open → counted (comptée) → closed (validée, Z numéroté).
  final String status;
  final int openingFloatMinor;
  final DateTime openedAt;
  final String? openedBy;
  final int? expectedCashMinor;
  final int? countedCashMinor;
  final int? differenceMinor;
  final String? countNote;
  final DateTime? countedAt;
  final String? countedBy;
  final DateTime? validatedAt;
  final String? validatedBy;
  final String? validationNote;
  final int? zNumber;
  final Map<int, int>? openingDetail;
  final Map<int, int>? countDetail;

  bool get isOpen => status == 'open';

  static Map<int, int>? _detail(Object? v) =>
      v == null ? null : {for (final e in (v as Map).entries) int.parse(e.key as String): (e.value as num).toInt()};
}

class MethodTotal {
  MethodTotal.fromJson(Map<String, dynamic> j)
      : name = j['name'] as String,
        kind = j['kind'] as String,
        total = _int(j['total']),
        tips = _int(j['tips']),
        count = _int(j['count']);
  final String name;
  final String kind;
  final int total;
  final int tips;
  final int count;
}

class SessionSummary {
  SessionSummary.fromJson(Map<String, dynamic> j)
      : openingFloat = _int(j['opening_float']),
        expectedCash = _int(j['expected_cash']),
        movementsIn = _int(j['movements_in']),
        movementsOut = _int(j['movements_out']),
        paymentsCount = _int(j['payments_count']),
        collected = _int(j['collected']),
        tips = _int(j['tips']),
        cashTips = _int(j['cash_tips']),
        voidedCount = _int(j['voided_count']),
        byMethod = [for (final m in (j['by_method'] as List? ?? const [])) MethodTotal.fromJson((m as Map).cast())],
        refunds = _int(j['refunds']);

  final int openingFloat;
  final int expectedCash;
  final int movementsIn;
  final int movementsOut;
  final int paymentsCount;
  final int collected;
  final int tips;
  final int cashTips;
  final int voidedCount;
  final List<MethodTotal> byMethod;
  final int refunds;
}

class CashMovement {
  CashMovement.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        kind = j['kind'] as String,
        amountMinor = _int(j['amount_minor']),
        reason = j['reason'] as String,
        createdBy = j['created_by'] as String?,
        createdAt = _date(j['created_at'])!;
  final String id;
  final String kind;
  final int amountMinor;
  final String reason;
  final String? createdBy;
  final DateTime createdAt;
}

class Payment {
  Payment.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        orderId = j['order_id'] as String,
        sessionId = j['session_id'] as String,
        method = j['method'] as String,
        methodName = ((j['payment_methods'] as Map?)?['name'] as String?) ?? (j['method'] as String),
        amountMinor = _int(j['amount_minor']),
        tipMinor = _int(j['tip_minor']),
        tenderedMinor = (j['tendered_minor'] as num?)?.toInt(),
        changeMinor = _int(j['change_minor']),
        reference = j['reference'] as String?,
        status = j['status'] as String,
        voidReason = j['void_reason'] as String?,
        createdBy = j['created_by'] as String?,
        createdAt = _date(j['created_at'])!,
        orderNumber = ((j['orders'] as Map?)?['number'] as num?)?.toInt(),
        receiptNumber = ((j['orders'] as Map?)?['receipt_number'] as num?)?.toInt(),
        refunded = [for (final r in (j['refunds'] as List? ?? const [])) _int((r as Map)['amount_minor'])].fold(0, (a, b) => a + b);

  final String id;
  final String orderId;
  final String sessionId;

  /// Type (cash, card, mobile_wallet…).
  final String method;

  /// Nom du mode choisi (« Espèces », « Pix », « Bon maison »…).
  final String methodName;
  final int amountMinor;
  final int tipMinor;
  final int? tenderedMinor;
  final int changeMinor;
  final String? reference;
  final String status;
  final String? voidReason;
  final String? createdBy;
  final DateTime createdAt;
  final int? orderNumber;
  final int? receiptNumber;
  final int refunded;

  bool get confirmed => status == 'confirmed';
  int get refundable => confirmed ? amountMinor - refunded : 0;
}

class PaymentResult {
  PaymentResult.fromJson(Map<String, dynamic> j)
      : paymentId = j['payment_id'] as String?,
        changeMinor = _int(j['change']),
        dueMinor = _int(j['due']),
        closed = j['closed'] as bool? ?? false,
        receiptNumber = (j['receipt_number'] as num?)?.toInt();
  final String? paymentId;
  final int changeMinor;
  final int dueMinor;
  final bool closed;
  final int? receiptNumber;
}

/// Rapport de caisse d'une période.
class CashReport {
  CashReport.fromJson(Map<String, dynamic> j)
      : salesTotal = _int(j['sales_total']),
        salesTax = _int(j['sales_tax']),
        discounts = _int(j['discounts']),
        ordersClosed = _int(j['orders_closed']),
        ordersCancelled = _int(j['orders_cancelled']),
        averageTicket = _int(j['average_ticket']),
        collected = _int(j['collected']),
        tips = _int(j['tips']),
        refunds = _int(j['refunds']),
        refundsCount = _int(j['refunds_count']),
        voided = _int(j['voided']),
        voidedCount = _int(j['voided_count']),
        paymentsCount = _int(j['payments_count']),
        fees = _int(j['fees']),
        byMethod = [for (final m in (j['by_method'] as List? ?? const [])) MethodTotal.fromJson((m as Map).cast())],
        byHour = {for (final h in (j['by_hour'] as List? ?? const [])) _int((h as Map)['hour']): _int(h['total'])},
        byDay = {for (final d in (j['by_day'] as List? ?? const [])) DateTime.parse((d as Map)['day'] as String): _int(d['total'])},
        byRegister = [for (final r in (j['by_register'] as List? ?? const [])) ((r as Map)['name'] as String, _int(r['total']))],
        byStaff = [
          for (final s in (j['by_staff'] as List? ?? const []))
            ((s as Map)['user_id'] as String?, _int(s['orders']), _int(s['sales']), _int(s['tips'])),
        ],
        sessions = [for (final s in (j['sessions'] as List? ?? const [])) (s as Map).cast<String, dynamic>()];

  final int salesTotal;
  final int salesTax;
  final int discounts;
  final int ordersClosed;
  final int ordersCancelled;
  final int averageTicket;
  final int collected;
  final int tips;
  final int refunds;
  final int refundsCount;
  final int voided;
  final int voidedCount;
  final int paymentsCount;
  final int fees;
  final List<MethodTotal> byMethod;
  final Map<int, int> byHour;
  final Map<DateTime, int> byDay;
  final List<(String, int)> byRegister;

  /// (utilisateur, commandes, ventes, pourboires)
  final List<(String?, int, int, int)> byStaff;
  final List<Map<String, dynamic>> sessions;
}

String _day(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class CashApi {
  CashApi(this._db);
  final SupabaseClient _db;

  /// Accès pour les extensions.
  SupabaseClient get db => _db;

  static const _paymentColumns = '*, payment_methods(name), orders(number, receipt_number), refunds(amount_minor)';

  // ------------------------------------------------------------ caisses, modes, coupures

  Future<List<CashRegister>> registers(String branchId) async {
    final rows = await _db.from('cash_registers').select('id, branch_id, name, active').eq('branch_id', branchId).order('name');
    return [
      for (final r in rows) CashRegister(r['id'] as String, r['branch_id'] as String, r['name'] as String, r['active'] as bool),
    ];
  }

  Future<void> saveRegister({required String orgId, required String branchId, String? id, required String name, bool active = true}) {
    if (id == null) {
      return _db.from('cash_registers').insert({'organization_id': orgId, 'branch_id': branchId, 'name': name.trim()});
    }
    return _db.from('cash_registers').update({'name': name.trim(), 'active': active}).eq('id', id);
  }

  Future<List<PaymentMethod>> paymentMethods(String orgId) async {
    final rows = await _db.from('payment_methods').select().eq('organization_id', orgId).order('sort_order').order('name');
    return [for (final r in rows) PaymentMethod.fromJson(r)];
  }

  Future<List<RefPaymentMethod>> catalog() async {
    final rows = await _db.from('ref_payment_methods').select().order('sort_order').order('name');
    return [for (final r in rows) RefPaymentMethod.fromJson(r)];
  }

  Future<void> addPaymentMethod({
    required String orgId,
    String? refCode,
    required String name,
    required String kind,
    required bool requiresReference,
    double feePercent = 0,
    int sortOrder = 100,
  }) =>
      _db.from('payment_methods').insert({
        'organization_id': orgId,
        'ref_code': refCode,
        'name': name.trim(),
        'kind': kind,
        'requires_reference': requiresReference,
        'fee_percent': feePercent,
        'sort_order': sortOrder,
      });

  Future<void> updatePaymentMethod(String id,
          {required String name,
          required bool requiresReference,
          required double feePercent,
          required List<String> branchIds,
          required bool active,
          required int sortOrder}) =>
      _db.from('payment_methods').update({
        'name': name.trim(),
        'requires_reference': requiresReference,
        'fee_percent': feePercent,
        'branch_ids': branchIds,
        'active': active,
        'sort_order': sortOrder,
      }).eq('id', id);

  Future<List<Denomination>> denominations(String currency) async {
    final rows = await _db.from('ref_currency_denominations').select('value_minor, kind').eq('currency', currency).order('value_minor', ascending: false);
    return [for (final r in rows) Denomination(_int(r['value_minor']), r['kind'] == 'note')];
  }

  /// Noms de l'équipe (utilisateur → nom affiché).
  Future<Map<String, String>> staff(String orgId) async {
    final rows = await _db.rpc('staff_directory', params: {'p_org': orgId}) as List;
    return {for (final r in rows) r['user_id'] as String: r['display_name'] as String};
  }

  // ------------------------------------------------------------ sessions

  Future<List<CashSession>> openSessions(String branchId) async {
    final rows = await _db.from('cash_sessions').select().eq('branch_id', branchId).eq('status', 'open');
    return [for (final r in rows) CashSession.fromJson(r)];
  }

  Future<CashSession?> activeSession(String registerId) async {
    final row = await _db
        .from('cash_sessions')
        .select()
        .eq('register_id', registerId)
        .neq('status', 'closed')
        .order('opened_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return row == null ? null : CashSession.fromJson(row);
  }

  /// Sessions à valider (comptées) et dernières clôtures.
  Future<List<CashSession>> closings(String branchId, {int limit = 60}) async {
    final rows = await _db
        .from('cash_sessions')
        .select()
        .eq('branch_id', branchId)
        .neq('status', 'open')
        .order('opened_at', ascending: false)
        .limit(limit);
    return [for (final r in rows) CashSession.fromJson(r)];
  }

  Future<SessionSummary> summary(String sessionId) async =>
      SessionSummary.fromJson((await _db.rpc('cash_session_summary', params: {'p_session': sessionId}) as Map).cast());

  Future<List<CashMovement>> movements(String sessionId) async {
    final rows = await _db.from('cash_movements').select().eq('session_id', sessionId).order('created_at', ascending: false);
    return [for (final r in rows) CashMovement.fromJson(r)];
  }

  Future<String> openSession(String registerId, int floatMinor, String clientId, {Map<int, int>? detail}) async =>
      await _db.rpc('open_cash_session', params: {
        'p_register': registerId,
        'p_float': floatMinor,
        'p_client_id': clientId,
        'p_detail': detail == null ? null : {for (final e in detail.entries.where((e) => e.value > 0)) '${e.key}': e.value},
      }) as String;

  Future<void> movement(String sessionId, String kind, int amountMinor, String reason, String clientId) =>
      _db.rpc('add_cash_movement', params: {
        'p_session': sessionId,
        'p_kind': kind,
        'p_amount': amountMinor,
        'p_reason': reason,
        'p_client_id': clientId,
      });

  Future<Map<String, dynamic>> count(String sessionId, int countedMinor, String? note, {Map<int, int>? detail}) async =>
      (await _db.rpc('count_cash_session', params: {
        'p_session': sessionId,
        'p_counted': countedMinor,
        'p_note': note,
        'p_detail': detail == null ? null : {for (final e in detail.entries.where((e) => e.value > 0)) '${e.key}': e.value},
      }) as Map)
          .cast();

  Future<void> validate(String sessionId, String? note) =>
      _db.rpc('validate_cash_session', params: {'p_session': sessionId, 'p_note': note});

  // ------------------------------------------------------------ paiements

  Future<List<Payment>> payments(String orderId) async {
    final rows = await _db.from('payments').select(_paymentColumns).eq('order_id', orderId).order('created_at');
    return [for (final r in rows) Payment.fromJson(r)];
  }

  Future<List<Payment>> sessionPayments(String sessionId) async {
    final rows = await _db.from('payments').select(_paymentColumns).eq('session_id', sessionId).order('created_at', ascending: false);
    return [for (final r in rows) Payment.fromJson(r)];
  }

  /// Paiements d'une période (journées locales de l'appareil).
  Future<List<Payment>> transactions(String branchId, DateTime from, DateTime to) async {
    final start = DateTime(from.year, from.month, from.day).toUtc().toIso8601String();
    final end = DateTime(to.year, to.month, to.day).add(const Duration(days: 1)).toUtc().toIso8601String();
    final rows = await _db
        .from('payments')
        .select(_paymentColumns)
        .eq('branch_id', branchId)
        .gte('created_at', start)
        .lt('created_at', end)
        .order('created_at', ascending: false)
        .limit(2000);
    return [for (final r in rows) Payment.fromJson(r)];
  }

  /// Recherche d'un ticket (n° de ticket ou n° de commande) pour remboursement.
  Future<List<Map<String, dynamic>>> findOrders(String branchId, int number) async {
    final rows = await _db
        .from('orders')
        .select('id, number, receipt_number, business_date, total_minor, paid_minor, status, opened_at')
        .eq('branch_id', branchId)
        .or('receipt_number.eq.$number,number.eq.$number')
        .order('opened_at', ascending: false)
        .limit(20);
    return [for (final r in rows) r];
  }

  Future<PaymentResult> take({
    required String orderId,
    required String sessionId,
    required String methodId,
    required int amountMinor,
    int tipMinor = 0,
    int? tenderedMinor,
    String? reference,
    required String clientId,
  }) async =>
      PaymentResult.fromJson((await _db.rpc('take_payment', params: {
        'p_order': orderId,
        'p_session': sessionId,
        'p_payment_method': methodId,
        'p_amount': amountMinor,
        'p_tip': tipMinor,
        'p_tendered': tenderedMinor,
        'p_reference': reference,
        'p_client_id': clientId,
      }) as Map)
          .cast());

  Future<void> voidPayment(String paymentId, String reason) =>
      _db.rpc('void_payment', params: {'p_payment': paymentId, 'p_reason': reason});

  Future<void> refund(String paymentId, String sessionId, int amountMinor, String reason, String clientId) =>
      _db.rpc('refund_payment', params: {
        'p_payment': paymentId,
        'p_session': sessionId,
        'p_amount': amountMinor,
        'p_reason': reason,
        'p_client_id': clientId,
      });

  Future<void> closeOrder(String orderId) => _db.rpc('close_order', params: {'p_order': orderId});

  // ------------------------------------------------------------ rapports

  Future<CashReport> report(String branchId, DateTime from, DateTime to) async => CashReport.fromJson(
      (await _db.rpc('cash_report', params: {'p_branch': branchId, 'p_from': _day(from), 'p_to': _day(to)}) as Map).cast());
}

/// Moyens utilisés par les dépenses et les règlements fournisseurs (009).
const paymentMethods = ['cash', 'card', 'mobile_money', 'transfer', 'other'];

class Refund {
  Refund.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        orderId = j['order_id'] as String,
        method = j['method'] as String,
        amountMinor = (j['amount_minor'] as num).toInt(),
        reason = j['reason'] as String,
        createdBy = j['created_by'] as String?,
        createdAt = DateTime.parse(j['created_at'] as String).toLocal(),
        orderNumber = ((j['orders'] as Map?)?['number'] as num?)?.toInt(),
        receiptNumber = ((j['orders'] as Map?)?['receipt_number'] as num?)?.toInt();
  final String id;
  final String orderId;
  final String method;
  final int amountMinor;
  final String reason;
  final String? createdBy;
  final DateTime createdAt;
  final int? orderNumber;
  final int? receiptNumber;
}

extension CashRefunds on CashApi {
  /// Remboursements récents d'un établissement (30 derniers jours).
  Future<List<Refund>> recentRefunds(String branchId) async {
    final since = DateTime.now().subtract(const Duration(days: 30)).toUtc().toIso8601String();
    final rows = await db
        .from('refunds')
        .select('*, orders(number, receipt_number)')
        .eq('branch_id', branchId)
        .gte('created_at', since)
        .order('created_at', ascending: false)
        .limit(200);
    return [for (final r in rows) Refund.fromJson(r)];
  }
}

/// Facture client (contenu figé à l'émission).
class CustomerInvoice {
  CustomerInvoice.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        orderId = j['order_id'] as String,
        number = (j['number'] as num).toInt(),
        label = j['label'] as String,
        issuedAt = DateTime.parse(j['issued_at'] as String).toLocal(),
        issuedBy = j['issued_by'] as String?,
        customerName = j['customer_name'] as String,
        customerCompany = j['customer_company'] as String?,
        customerTaxId = j['customer_tax_id'] as String?,
        customerAddress = j['customer_address'] as String?,
        customerEmail = j['customer_email'] as String?,
        currency = j['currency'] as String,
        pricesIncludeTax = j['prices_include_tax'] as bool,
        taxRate = (j['tax_rate'] as num).toDouble(),
        subtotalMinor = (j['subtotal_minor'] as num).toInt(),
        taxMinor = (j['tax_minor'] as num).toInt(),
        totalMinor = (j['total_minor'] as num).toInt(),
        paidMinor = (j['paid_minor'] as num).toInt(),
        discountMinor = (j['discount_minor'] as num? ?? 0).toInt(),
        deliveryFeeMinor = (j['delivery_fee_minor'] as num? ?? 0).toInt(),
        lines = [for (final l in (j['lines'] as List? ?? const [])) (l as Map).cast<String, dynamic>()],
        adjustments = [for (final a in (j['adjustments'] as List? ?? const [])) (a as Map).cast<String, dynamic>()],
        payments = [for (final p in (j['payments'] as List? ?? const [])) (p as Map).cast<String, dynamic>()],
        status = j['status'] as String,
        cancelReason = j['cancel_reason'] as String?,
        orderNumber = ((j['orders'] as Map?)?['number'] as num?)?.toInt(),
        receiptNumber = ((j['orders'] as Map?)?['receipt_number'] as num?)?.toInt();

  final String id;
  final String orderId;
  final int number;
  final String label;
  final DateTime issuedAt;
  final String? issuedBy;
  final String customerName;
  final String? customerCompany;
  final String? customerTaxId;
  final String? customerAddress;
  final String? customerEmail;
  final String currency;
  final bool pricesIncludeTax;
  final double taxRate;
  final int subtotalMinor;
  final int taxMinor;
  final int totalMinor;
  final int paidMinor;
  final int discountMinor;
  final int deliveryFeeMinor;
  final List<Map<String, dynamic>> lines;
  final List<Map<String, dynamic>> adjustments;
  final List<Map<String, dynamic>> payments;
  final String status;
  final String? cancelReason;
  final int? orderNumber;
  final int? receiptNumber;

  bool get cancelled => status == 'cancelled';
  int get dueMinor => totalMinor - paidMinor;
}

extension CashInvoices on CashApi {
  static const _columns = '*, orders(number, receipt_number)';

  Future<CustomerInvoice> issueInvoice({
    required String orderId,
    required String customerName,
    String? company,
    String? taxId,
    String? address,
    String? email,
  }) async {
    final r = (await db.rpc('issue_invoice', params: {
      'p_order': orderId,
      'p_customer_name': customerName,
      'p_company': company,
      'p_tax_id': taxId,
      'p_address': address,
      'p_email': email,
    }) as Map)
        .cast<String, dynamic>();
    return invoice(r['invoice_id'] as String);
  }

  Future<CustomerInvoice> invoice(String id) async =>
      CustomerInvoice.fromJson(await db.from('customer_invoices').select(_columns).eq('id', id).single());

  /// Facture valable d'une commande (null si aucune).
  Future<CustomerInvoice?> invoiceForOrder(String orderId) async {
    final row = await db.from('customer_invoices').select(_columns).eq('order_id', orderId).eq('status', 'issued').maybeSingle();
    return row == null ? null : CustomerInvoice.fromJson(row);
  }

  Future<List<CustomerInvoice>> invoices(String branchId, DateTime from, DateTime to) async {
    final start = DateTime(from.year, from.month, from.day).toUtc().toIso8601String();
    final end = DateTime(to.year, to.month, to.day).add(const Duration(days: 1)).toUtc().toIso8601String();
    final rows = await db
        .from('customer_invoices')
        .select(_columns)
        .eq('branch_id', branchId)
        .gte('issued_at', start)
        .lt('issued_at', end)
        .order('number', ascending: false)
        .limit(1000);
    return [for (final r in rows) CustomerInvoice.fromJson(r)];
  }

  Future<void> cancelInvoice(String id, String reason) =>
      db.rpc('cancel_invoice', params: {'p_invoice': id, 'p_reason': reason});
}
