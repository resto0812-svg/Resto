import 'package:flutter/material.dart';

import '../../data/stock_api.dart';
import '../../ui/branch_scope.dart';
import '../../ui/common.dart';
import '../stock/stock_widgets.dart';

/// Ligne d'achat en saisie : ingrédient, quantité, unité, prix unitaire
/// (en unités principales de la monnaie, par unité saisie).
class PurchaseLineDraft {
  PurchaseLineDraft({this.ingredientId, this.unit, String qty = '', String price = '', this.poLineId})
      : qty = TextEditingController(text: qty),
        price = TextEditingController(text: price);
  String? ingredientId;
  String? unit;
  final String? poLineId;
  final TextEditingController qty;
  final TextEditingController price;

  void dispose() {
    qty.dispose();
    price.dispose();
  }

  /// Ligne prête à envoyer au serveur ; null si incomplète.
  Map<String, dynamic>? toJson(BranchContext scope) {
    final q = parseQty(qty.text);
    final p = price.text.trim().isEmpty ? 0.0 : parseQty(price.text);
    if (ingredientId == null || unit == null || q == null || q <= 0 || p == null) return null;
    return {
      'ingredient_id': ingredientId,
      'quantity': q,
      'unit': unit,
      'unit_price': scope.toMinor(p),
      'po_line_id': ?poLineId,
    };
  }
}

class PurchaseLinesEditor extends StatefulWidget {
  const PurchaseLinesEditor({
    super.key,
    required this.lines,
    required this.ingredients,
    required this.units,
    required this.scope,
    this.lockIngredients = false,
  });

  final List<PurchaseLineDraft> lines;
  final List<Ingredient> ingredients;
  final List<Unit> units;
  final BranchContext scope;
  final bool lockIngredients;

  @override
  State<PurchaseLinesEditor> createState() => _PurchaseLinesEditorState();
}

class _PurchaseLinesEditorState extends State<PurchaseLinesEditor> {
  Ingredient? _ing(String? id) => widget.ingredients.where((i) => i.id == id).firstOrNull;

  double get _total {
    var sum = 0.0;
    for (final l in widget.lines) {
      final q = parseQty(l.qty.text) ?? 0;
      final p = parseQty(l.price.text) ?? 0;
      sum += q * widget.scope.toMinor(p);
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final l in widget.lines)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Wrap(spacing: 12, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            SizedBox(
              width: 240,
              child: SearchSelect(
                label: t.ingredient,
                value: l.ingredientId,
                enabled: !widget.lockIngredients,
                entries: [for (final i in widget.ingredients.where((i) => i.active || i.id == l.ingredientId)) (i.id, i.name)],
                onChanged: (v) => setState(() {
                  l.ingredientId = v;
                  l.unit = _ing(v)?.unitCode;
                }),
              ),
            ),
            SizedBox(
              width: 100,
              child: TextField(
                controller: l.qty,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: t.quantity),
                onChanged: (_) => setState(() {}),
              ),
            ),
            if (_ing(l.ingredientId) != null)
              DropdownButton<String>(
                value: l.unit,
                items: [
                  for (final u in compatibleUnits(widget.units, _ing(l.ingredientId)!.unitCode))
                    DropdownMenuItem(value: u.code, child: Text(unitLabel(t, u.code))),
                ],
                onChanged: (v) => setState(() => l.unit = v),
              ),
            SizedBox(
              width: 150,
              child: TextField(
                controller: l.price,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: t.unitPrice(l.unit == null ? '' : unitLabel(t, l.unit!)),
                  suffixText: widget.scope.currency,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            if (!widget.lockIngredients)
              IconButton(
                tooltip: t.removeLine,
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => setState(() {
                  widget.lines.remove(l);
                  l.dispose();
                }),
              ),
          ]),
        ),
      Row(children: [
        if (!widget.lockIngredients)
          TextButton.icon(
            onPressed: () => setState(() => widget.lines.add(PurchaseLineDraft())),
            icon: const Icon(Icons.add),
            label: Text(t.addIngredientLine),
          ),
        const Spacer(),
        Text(t.totalAmount(widget.scope.money(context, _total)), style: Theme.of(context).textTheme.titleMedium),
      ]),
    ]);
  }
}

String purchaseStatusLabel(BuildContext context, String s) {
  final t = context.t;
  return switch (s) {
    'draft' => t.poDraft,
    'sent' => t.poSent,
    'partially_received' => t.poPartial,
    'received' => t.poReceived,
    _ => t.poCancelled,
  };
}
