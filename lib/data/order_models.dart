/// Commandes : lecture seule côté application (toutes les écritures passent
/// par les fonctions du serveur, qui fixent prix et contrôles).
library;

DateTime? _date(Object? v) => v == null ? null : DateTime.parse(v as String);

class OrderLineOption {
  OrderLineOption.fromJson(Map<String, dynamic> j)
      : groupName = j['group_name'] as String,
        name = j['modifier_name'] as String,
        priceMinor = (j['price_minor'] as num).toInt();

  final String groupName;
  final String name;
  final int priceMinor;
}

class OrderLine {
  OrderLine.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        itemId = j['item_id'] as String?,
        itemName = j['item_name'] as String,
        variantName = j['variant_name'] as String,
        quantity = (j['quantity'] as num).toInt(),
        unitPriceMinor = (j['unit_price_minor'] as num).toInt(),
        lineTotalMinor = (j['line_total_minor'] as num).toInt(),
        note = j['note'] as String?,
        prepStatus = j['prep_status'] as String,
        held = j['held'] as bool? ?? false,
        addedVia = j['added_via'] as String? ?? 'staff',
        stationId = j['station_id'] as String?,
        cancelReason = j['cancel_reason'] as String?,
        addedAt = DateTime.parse(j['added_at'] as String),
        sentAt = _date(j['sent_at']),
        readyAt = _date(j['ready_at']),
        servedAt = _date(j['served_at']),
        options = [
          for (final m in (j['order_item_modifiers'] as List? ?? const []))
            OrderLineOption.fromJson((m as Map).cast<String, dynamic>()),
        ];

  final String id;
  final String? itemId;
  final String itemName;
  final String variantName;
  final int quantity;
  final int unitPriceMinor;
  final int lineTotalMinor;
  final String? note;
  final String prepStatus;

  /// « À suivre » : attend « Lancer la suite » avant de partir en cuisine.
  final bool held;
  final String addedVia;
  final String? stationId;
  final String? cancelReason;
  final DateTime addedAt;
  final DateTime? sentAt;
  final DateTime? readyAt;
  final DateTime? servedAt;
  final List<OrderLineOption> options;

  bool get pending => prepStatus == 'pending';
  bool get cancelled => prepStatus == 'cancelled';
  bool get inKitchen => prepStatus == 'sent' || prepStatus == 'preparing';
  bool get ready => prepStatus == 'ready';
  bool get served => prepStatus == 'served';
  String get title => variantName.isEmpty ? itemName : '$itemName ($variantName)';
}

/// Réduction appliquée (promotion, fidélité, remise manuelle).
class OrderAdjustment {
  OrderAdjustment.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        kind = j['kind'] as String,
        label = j['label'] as String,
        percent = (j['percent'] as num?)?.toDouble(),
        appliedMinor = (j['applied_minor'] as num? ?? 0).toInt(),
        createdAt = DateTime.parse(j['created_at'] as String);

  final String id;
  final String kind; // promotion, loyalty, manual
  final String label;
  final double? percent;
  final int appliedMinor;
  final DateTime createdAt;
}

/// Étape de la commande dans le service, de la prise au paiement.
enum OrderStage {
  /// Commande d'un client à accepter ou refuser.
  toValidate,

  /// Prise de commande en cours : rien n'est encore parti en cuisine.
  draft,

  /// En préparation (cuisine, bar).
  cooking,

  /// Au moins un article prêt à servir / à remettre.
  ready,

  /// Tout est servi (ou remis) : reste à encaisser.
  toPay,

  /// Payée et remise : terminée.
  done,

  /// Annulée.
  cancelled,
}

class Order {
  Order.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        branchId = j['branch_id'] as String,
        number = (j['number'] as num).toInt(),
        businessDate = j['business_date'] as String? ?? '',
        channel = j['channel'] as String,
        tableId = j['table_id'] as String?,
        guests = (j['guests'] as num?)?.toInt(),
        status = j['status'] as String,
        currency = j['currency'] as String,
        pricesIncludeTax = j['prices_include_tax'] as bool,
        taxRate = (j['tax_rate'] as num).toDouble(),
        subtotalMinor = (j['subtotal_minor'] as num).toInt(),
        taxMinor = (j['tax_minor'] as num).toInt(),
        totalMinor = (j['total_minor'] as num).toInt(),
        paidMinor = (j['paid_minor'] as num? ?? 0).toInt(),
        openedAt = DateTime.parse(j['opened_at'] as String),
        openedBy = j['opened_by'] as String?,
        closedAt = _date(j['closed_at']),
        cancelledAt = _date(j['cancelled_at']),
        cancelReason = j['cancel_reason'] as String?,
        source = j['source'] as String? ?? 'staff',
        note = j['note'] as String?,
        acceptance = j['acceptance'] as String? ?? 'accepted',
        customerUserId = j['customer_user_id'] as String?,
        customerName = j['customer_name'] as String?,
        contactPhone = j['contact_phone'] as String?,
        deliveryAddress = j['delivery_address'] as String?,
        deliveryInstructions = j['delivery_instructions'] as String?,
        scheduledFor = _date(j['scheduled_for']),
        promisedAt = _date(j['promised_at']),
        readyAt = _date(j['ready_at']),
        servedAt = _date(j['served_at']),
        reservationId = j['reservation_id'] as String?,
        receiptNumberOrNull = (j['receipt_number'] as num?)?.toInt(),
        deliveryFeeMinor = (j['delivery_fee_minor'] as num? ?? 0).toInt(),
        discountMinor = (j['discount_minor'] as num? ?? 0).toInt(),
        rejectReason = j['reject_reason'] as String?,
        adjustments = [
          for (final a in (j['order_adjustments'] as List? ?? const []))
            OrderAdjustment.fromJson((a as Map).cast<String, dynamic>()),
        ]..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
        lines = [
          for (final l in (j['order_items'] as List? ?? const [])) OrderLine.fromJson((l as Map).cast<String, dynamic>()),
        ]..sort((a, b) => a.addedAt.compareTo(b.addedAt));

  final String id;
  final String branchId;
  final int number;
  final String businessDate;
  final String channel;
  final String? tableId;
  final int? guests;
  final String status;
  final String currency;
  final bool pricesIncludeTax;
  final double taxRate;
  final int subtotalMinor;
  final int taxMinor;
  final int totalMinor;
  final int paidMinor;
  final DateTime openedAt;
  final String? openedBy;
  final DateTime? closedAt;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final List<OrderLine> lines;

  /// staff (serveur, comptoir), phone, qr (table), app / web (client).
  final String source;
  final String? note;

  /// pending = commande d'un client en attente de validation par le restaurant.
  final String acceptance;
  final String? customerUserId;
  final String? customerName;
  final String? contactPhone;
  final String? deliveryAddress;
  final String? deliveryInstructions;
  final DateTime? scheduledFor;

  /// Heure promise au client (délai annoncé).
  final DateTime? promisedAt;
  final DateTime? readyAt;
  final DateTime? servedAt;
  final String? reservationId;

  /// Numéro de ticket légal (attribué à la clôture).
  final int? receiptNumberOrNull;
  final int deliveryFeeMinor;
  final int discountMinor;
  final String? rejectReason;
  final List<OrderAdjustment> adjustments;

  int get dueMinor => totalMinor - paidMinor;
  bool get isOpen => status == 'open';
  bool get isPaid => paidMinor >= totalMinor && totalMinor > 0;
  bool get awaitingAcceptance => acceptance == 'pending' && status == 'open';
  bool get fromCustomer => source == 'app' || source == 'qr' || source == 'web';

  List<OrderLine> get activeLines => lines.where((l) => !l.cancelled).toList();
  int get pendingCount => lines.where((l) => l.pending && !l.held).length;
  int get heldCount => lines.where((l) => l.pending && l.held).length;
  int get readyCount => lines.where((l) => l.ready).length;
  int get cookingCount => lines.where((l) => l.inKitchen).length;
  bool get hasSentLines => lines.any((l) => !l.pending && !l.cancelled);
  int get itemsCount => activeLines.fold(0, (a, l) => a + l.quantity);

  OrderStage get stage {
    if (status == 'cancelled') return OrderStage.cancelled;
    if (awaitingAcceptance) return OrderStage.toValidate;
    final active = activeLines;
    if (active.isNotEmpty && active.every((l) => l.served)) {
      return status == 'closed' ? OrderStage.done : OrderStage.toPay;
    }
    if (active.any((l) => l.ready)) return OrderStage.ready;
    if (active.any((l) => l.inKitchen)) return OrderStage.cooking;
    if (status == 'closed') return OrderStage.done;
    return OrderStage.draft;
  }

  /// Minutes depuis l'envoi en cuisine du premier article (null si rien n'est parti).
  int? get minutesInKitchen {
    final sent = lines.map((l) => l.sentAt).whereType<DateTime>();
    if (sent.isEmpty) return null;
    final first = sent.reduce((a, b) => a.isBefore(b) ? a : b);
    return DateTime.now().difference(first).inMinutes;
  }
}

/// Évènement du journal d'une commande.
class OrderEvent {
  OrderEvent.fromJson(Map<String, dynamic> j)
      : event = j['event'] as String,
        detail = (j['detail'] as Map?)?.cast<String, dynamic>() ?? const {},
        actorId = j['actor_id'] as String?,
        createdAt = DateTime.parse(j['created_at'] as String);
  final String event;
  final Map<String, dynamic> detail;
  final String? actorId;
  final DateTime createdAt;
}
