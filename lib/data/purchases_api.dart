import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Achats, fournisseurs, dépenses, justificatifs et rapport financier.
class Supplier {
  Supplier.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        name = j['name'] as String,
        contactName = j['contact_name'] as String?,
        phone = j['phone'] as String?,
        email = j['email'] as String?,
        taxId = j['tax_id'] as String?,
        address = j['address'] as String?,
        paymentTermsDays = (j['payment_terms_days'] as num).toInt(),
        active = j['active'] as bool;
  final String id;
  final String name;
  final String? contactName;
  final String? phone;
  final String? email;
  final String? taxId;
  final String? address;
  final int paymentTermsDays;
  final bool active;
}

class PurchaseLine {
  PurchaseLine.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        ingredientId = j['ingredient_id'] as String,
        quantity = (j['quantity'] as num).toDouble(),
        unitCode = j['unit_code'] as String,
        unitPrice = (j['unit_price'] as num).toDouble(),
        receivedQuantity = (j['received_quantity'] as num? ?? 0).toDouble();
  final String id;
  final String ingredientId;
  final double quantity;
  final String unitCode;
  final double unitPrice;
  final double receivedQuantity;
}

class PurchaseOrder {
  PurchaseOrder.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        supplierId = j['supplier_id'] as String,
        number = (j['number'] as num).toInt(),
        status = j['status'] as String,
        expectedOn = j['expected_on'] == null ? null : DateTime.parse(j['expected_on'] as String),
        totalMinor = (j['total_minor'] as num).toInt(),
        note = j['note'] as String?,
        lines = [for (final l in (j['purchase_order_lines'] as List? ?? const [])) PurchaseLine.fromJson((l as Map).cast())];
  final String id;
  final String supplierId;
  final int number;
  final String status;
  final DateTime? expectedOn;
  final int totalMinor;
  final String? note;
  final List<PurchaseLine> lines;
}

class GoodsReceipt {
  GoodsReceipt.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        supplierId = j['supplier_id'] as String,
        poId = j['po_id'] as String?,
        reference = j['reference'] as String?,
        totalMinor = (j['total_minor'] as num).toInt(),
        receivedAt = DateTime.parse(j['received_at'] as String);
  final String id;
  final String supplierId;
  final String? poId;
  final String? reference;
  final int totalMinor;
  final DateTime receivedAt;
}

class SupplierInvoice {
  SupplierInvoice.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        supplierId = j['supplier_id'] as String,
        number = j['number'] as String,
        invoiceDate = DateTime.parse(j['invoice_date'] as String),
        dueDate = j['due_date'] == null ? null : DateTime.parse(j['due_date'] as String),
        totalMinor = (j['total_minor'] as num).toInt(),
        paidMinor = (j['paid_minor'] as num).toInt(),
        status = j['status'] as String,
        attachmentPath = j['attachment_path'] as String?,
        payments = [for (final p in (j['supplier_payments'] as List? ?? const [])) SupplierPayment.fromJson((p as Map).cast())];
  final String id;
  final String supplierId;
  final String number;
  final DateTime invoiceDate;
  final DateTime? dueDate;
  final int totalMinor;
  final int paidMinor;
  final String status;
  final String? attachmentPath;
  final List<SupplierPayment> payments;

  int get dueMinor => totalMinor - paidMinor;
}

class SupplierPayment {
  SupplierPayment.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        amountMinor = (j['amount_minor'] as num).toInt(),
        method = j['method'] as String,
        paidOn = DateTime.parse(j['paid_on'] as String),
        status = j['status'] as String;
  final String id;
  final int amountMinor;
  final String method;
  final DateTime paidOn;
  final String status;
}

class ExpenseCategory {
  ExpenseCategory(this.id, this.code, this.name, this.active);
  final String id;
  final String? code;
  final String name;
  final bool active;
}

class Expense {
  Expense.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        categoryId = j['category_id'] as String,
        description = j['description'] as String,
        expenseDate = DateTime.parse(j['expense_date'] as String),
        amountMinor = (j['amount_minor'] as num).toInt(),
        taxMinor = (j['tax_minor'] as num).toInt(),
        method = j['method'] as String,
        status = j['status'] as String,
        attachmentPath = j['attachment_path'] as String?,
        cancelReason = j['cancel_reason'] as String?;
  final String id;
  final String categoryId;
  final String description;
  final DateTime expenseDate;
  final int amountMinor;
  final int taxMinor;
  final String method;
  final String status;
  final String? attachmentPath;
  final String? cancelReason;
}

/// Dépense récurrente (loyer, abonnement…) générée chaque mois.
class ExpenseTemplate {
  ExpenseTemplate.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        categoryId = j['category_id'] as String,
        supplierId = j['supplier_id'] as String?,
        description = j['description'] as String,
        amountMinor = (j['amount_minor'] as num).toInt(),
        taxMinor = (j['tax_minor'] as num? ?? 0).toInt(),
        method = j['method'] as String? ?? 'transfer',
        dayOfMonth = (j['day_of_month'] as num? ?? 1).toInt(),
        active = j['active'] as bool? ?? true,
        lastMonth = j['last_month'] == null ? null : DateTime.parse(j['last_month'] as String);
  final String id;
  final String categoryId;
  final String? supplierId;
  final String description;
  final int amountMinor;
  final int taxMinor;
  final String method;
  final int dayOfMonth;
  final bool active;
  final DateTime? lastMonth;

  /// Pas encore générée pour le mois en cours.
  bool get dueThisMonth {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    return active && (lastMonth == null || lastMonth!.isBefore(month));
  }
}

class FinanceSummary {
  FinanceSummary.fromJson(Map<String, dynamic> j)
      : salesTtc = (j['sales_ttc'] as num).toInt(),
        salesTax = (j['sales_tax'] as num).toInt(),
        salesHt = (j['sales_ht'] as num).toInt(),
        ordersClosed = (j['orders_closed'] as num).toInt(),
        collected = (j['collected'] as num).toInt(),
        cogs = (j['cogs'] as num).toInt(),
        losses = (j['losses'] as num).toInt(),
        purchases = (j['purchases'] as num).toInt(),
        expensesHt = (j['expenses_ht'] as num).toInt(),
        grossMargin = (j['gross_margin'] as num).toInt(),
        estimatedResult = (j['estimated_result'] as num).toInt(),
        supplierDebt = (j['supplier_debt'] as num).toInt(),
        expensesByCategory = [
          for (final c in (j['expenses_by_category'] as List))
            ((c as Map)['code'] as String?, c['name'] as String, (c['total'] as num).toInt()),
        ];
  final int salesTtc;
  final int salesTax;
  final int salesHt;
  final int ordersClosed;
  final int collected;
  final int cogs;
  final int losses;
  final int purchases;
  final int expensesHt;
  final int grossMargin;
  final int estimatedResult;
  final int supplierDebt;
  final List<(String?, String, int)> expensesByCategory;
}

String _day(DateTime d) => d.toIso8601String().substring(0, 10);

class PurchasesApi {
  PurchasesApi(this._db);
  final SupabaseClient _db;

  // ------------------------------------------------------------ fournisseurs
  Future<List<Supplier>> suppliers(String orgId) async {
    final rows = await _db.from('suppliers').select().eq('organization_id', orgId).order('name');
    return [for (final r in rows) Supplier.fromJson(r)];
  }

  Future<void> saveSupplier(String orgId, String? id, Map<String, dynamic> values) {
    if (id == null) return _db.from('suppliers').insert({...values, 'organization_id': orgId});
    return _db.from('suppliers').update(values).eq('id', id);
  }

  // ------------------------------------------------------------ commandes, réceptions
  Future<List<PurchaseOrder>> purchaseOrders(String branchId) async {
    final rows = await _db
        .from('purchase_orders')
        .select('*, purchase_order_lines(*)')
        .eq('branch_id', branchId)
        .order('created_at', ascending: false)
        .limit(50);
    return [for (final r in rows) PurchaseOrder.fromJson(r)];
  }

  Future<String> savePurchaseOrder({
    String? id,
    required String branchId,
    required String supplierId,
    DateTime? expectedOn,
    String? note,
    required List<Map<String, dynamic>> lines,
  }) async =>
      await _db.rpc('save_purchase_order', params: {
        'p_id': id,
        'p_branch': branchId,
        'p_supplier': supplierId,
        'p_expected_on': expectedOn == null ? null : _day(expectedOn),
        'p_note': note,
        'p_lines': lines,
      }) as String;

  Future<void> setPurchaseOrderStatus(String id, String status, [String? reason]) =>
      _db.rpc('set_purchase_order_status', params: {'p_id': id, 'p_status': status, 'p_reason': reason});

  Future<List<GoodsReceipt>> receipts(String branchId) async {
    final rows = await _db.from('goods_receipts').select().eq('branch_id', branchId).order('received_at', ascending: false).limit(50);
    return [for (final r in rows) GoodsReceipt.fromJson(r)];
  }

  Future<String> recordReceipt({
    required String branchId,
    required String locationId,
    required String supplierId,
    String? poId,
    String? reference,
    required List<Map<String, dynamic>> lines,
    required String clientId,
  }) async =>
      await _db.rpc('record_goods_receipt', params: {
        'p_branch': branchId,
        'p_location': locationId,
        'p_supplier': supplierId,
        'p_po': poId,
        'p_reference': reference,
        'p_lines': lines,
        'p_client_id': clientId,
      }) as String;

  // ------------------------------------------------------------ factures
  Future<List<SupplierInvoice>> invoices(String branchId) async {
    final rows = await _db
        .from('supplier_invoices')
        .select('*, supplier_payments(id, amount_minor, method, paid_on, status)')
        .eq('branch_id', branchId)
        .order('invoice_date', ascending: false)
        .limit(100);
    return [for (final r in rows) SupplierInvoice.fromJson(r)];
  }

  Future<void> recordInvoice({
    required String branchId,
    required String supplierId,
    required String number,
    required DateTime date,
    DateTime? dueDate,
    required int subtotalMinor,
    required int taxMinor,
    List<String> receiptIds = const [],
    String? attachmentPath,
    required String clientId,
  }) =>
      _db.rpc('record_supplier_invoice', params: {
        'p_branch': branchId,
        'p_supplier': supplierId,
        'p_number': number,
        'p_invoice_date': _day(date),
        'p_due_date': dueDate == null ? null : _day(dueDate),
        'p_subtotal': subtotalMinor,
        'p_tax': taxMinor,
        'p_receipts': receiptIds,
        'p_attachment': attachmentPath,
        'p_client_id': clientId,
      });

  Future<void> payInvoice(String invoiceId, int amountMinor, String method, DateTime paidOn, String? reference,
          String? cashSessionId, String clientId) =>
      _db.rpc('record_supplier_payment', params: {
        'p_invoice': invoiceId,
        'p_amount': amountMinor,
        'p_method': method,
        'p_paid_on': _day(paidOn),
        'p_reference': reference,
        'p_cash_session': cashSessionId,
        'p_client_id': clientId,
      });

  Future<void> voidSupplierPayment(String id, String reason) =>
      _db.rpc('void_supplier_payment', params: {'p_payment': id, 'p_reason': reason});

  Future<void> cancelInvoice(String id, String reason) =>
      _db.rpc('cancel_supplier_invoice', params: {'p_invoice': id, 'p_reason': reason});

  // ------------------------------------------------------------ dépenses
  Future<List<ExpenseCategory>> categories(String orgId) async {
    final rows = await _db.from('expense_categories').select().eq('organization_id', orgId).order('name');
    return [
      for (final r in rows) ExpenseCategory(r['id'] as String, r['code'] as String?, r['name'] as String, r['active'] as bool),
    ];
  }

  Future<void> addCategory(String orgId, String name) =>
      _db.from('expense_categories').insert({'organization_id': orgId, 'name': name.trim()});

  Future<List<Expense>> expenses(String branchId, DateTime from, DateTime to) async {
    final rows = await _db
        .from('expenses')
        .select()
        .eq('branch_id', branchId)
        .gte('expense_date', _day(from))
        .lte('expense_date', _day(to))
        .order('expense_date', ascending: false)
        .order('created_at', ascending: false);
    return [for (final r in rows) Expense.fromJson(r)];
  }

  Future<void> recordExpense({
    required String branchId,
    required String categoryId,
    required String description,
    required DateTime date,
    required int amountMinor,
    required int taxMinor,
    required String method,
    String? supplierId,
    String? cashSessionId,
    String? attachmentPath,
    required String clientId,
  }) =>
      _db.rpc('record_expense', params: {
        'p_branch': branchId,
        'p_category': categoryId,
        'p_description': description,
        'p_expense_date': _day(date),
        'p_amount': amountMinor,
        'p_tax': taxMinor,
        'p_method': method,
        'p_supplier': supplierId,
        'p_cash_session': cashSessionId,
        'p_attachment': attachmentPath,
        'p_client_id': clientId,
      });

  // --- Dépenses récurrentes et budgets

  Future<List<ExpenseTemplate>> expenseTemplates(String branchId) async {
    try {
      final rows = await _db.from('expense_templates').select().eq('branch_id', branchId).order('day_of_month');
      return [for (final r in rows) ExpenseTemplate.fromJson(r)];
    } on PostgrestException {
      return const [];
    }
  }

  Future<void> saveExpenseTemplate(String orgId, String branchId, String? id, Map<String, dynamic> values) => id == null
      ? _db.from('expense_templates').insert({...values, 'organization_id': orgId, 'branch_id': branchId})
      : _db.from('expense_templates').update(values).eq('id', id);

  Future<void> deleteExpenseTemplate(String id) => _db.from('expense_templates').delete().eq('id', id);

  /// Catégorie → budget mensuel.
  Future<Map<String, int>> expenseBudgets(String branchId) async {
    try {
      final rows = await _db.from('expense_budgets').select('category_id, monthly_minor').eq('branch_id', branchId);
      return {for (final r in rows) r['category_id'] as String: (r['monthly_minor'] as num).toInt()};
    } on PostgrestException {
      return const {};
    }
  }

  Future<void> setExpenseBudget(String orgId, String branchId, String categoryId, int? monthlyMinor) => monthlyMinor == null
      ? _db.from('expense_budgets').delete().eq('branch_id', branchId).eq('category_id', categoryId)
      : _db.from('expense_budgets').upsert(
          {'organization_id': orgId, 'branch_id': branchId, 'category_id': categoryId, 'monthly_minor': monthlyMinor},
          onConflict: 'branch_id,category_id',
        );

  /// Génère les dépenses récurrentes du mois ; renvoie leur nombre.
  Future<int> generateRecurringExpenses(String branchId) async =>
      ((await _db.rpc('generate_recurring_expenses', params: {'p_branch': branchId})) as num).toInt();

  Future<void> cancelExpense(String id, String reason) =>
      _db.rpc('cancel_expense', params: {'p_expense': id, 'p_reason': reason});

  // ------------------------------------------------------------ justificatifs
  /// Dépose un justificatif dans {organisation}/{établissement}/ ; renvoie son chemin.
  Future<String> uploadDocument(String orgId, String branchId, String id, String extension, Uint8List bytes) async {
    final ext = extension.toLowerCase();
    final path = '$orgId/$branchId/$id.$ext';
    final type = switch (ext) {
      'pdf' => 'application/pdf',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
    await _db.storage.from('documents').uploadBinary(path, bytes, fileOptions: FileOptions(contentType: type));
    return path;
  }

  /// Lien temporaire (5 minutes) pour consulter un justificatif privé.
  Future<String> documentUrl(String path) => _db.storage.from('documents').createSignedUrl(path, 300);

  // ------------------------------------------------------------ rapport
  Future<FinanceSummary> finance(String branchId, DateTime from, DateTime to) async => FinanceSummary.fromJson(
      (await _db.rpc('finance_summary', params: {'p_branch': branchId, 'p_from': _day(from), 'p_to': _day(to)}) as Map).cast());

  /// Données brutes pour les exports CSV.
  Future<List<Map<String, dynamic>>> ordersForExport(String branchId, DateTime from, DateTime to) async =>
      List<Map<String, dynamic>>.from(await _db
          .from('orders')
          .select('number, business_date, channel, status, subtotal_minor, tax_minor, total_minor, paid_minor, opened_at, closed_at')
          .eq('branch_id', branchId)
          .gte('business_date', _day(from))
          .lte('business_date', _day(to))
          .order('business_date')
          .order('number'));

  Future<List<Map<String, dynamic>>> paymentsForExport(String branchId, DateTime from, DateTime to) async =>
      List<Map<String, dynamic>>.from(await _db
          .from('payments')
          .select('created_at, method, amount_minor, status, reference, orders(number)')
          .eq('branch_id', branchId)
          .gte('created_at', from.toUtc().toIso8601String())
          .lt('created_at', to.add(const Duration(days: 1)).toUtc().toIso8601String())
          .order('created_at'));
}
