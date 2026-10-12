import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/stock_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/common.dart';

String unitLabel(AppLocalizations t, String code) => switch (code) {
      'unit' => t.unitPiece,
      'dozen' => t.unitDozen,
      _ => code,
    };

String ingredientKindLabel(AppLocalizations t, String k) => switch (k) {
      'raw' => t.ingRaw,
      'beverage' => t.ingBeverage,
      'packaging' => t.ingPackaging,
      'semi_finished' => t.ingSemiFinished,
      _ => t.ingConsumable,
    };

String movementLabel(AppLocalizations t, String k) => switch (k) {
      'opening' => t.mvOpening,
      'receipt' => t.mvReceipt,
      'sale' => t.mvSale,
      'production_in' => t.mvProductionIn,
      'production_out' => t.mvProductionOut,
      'waste' => t.mvWaste,
      'staff_meal' => t.mvStaffMeal,
      'return' => t.mvReturn,
      'transfer_in' => t.mvTransferIn,
      'transfer_out' => t.mvTransferOut,
      'adjustment' => t.mvAdjustment,
      _ => t.mvInventory,
    };

String storageLabel(AppLocalizations t, String s) => switch (s) {
      'chilled' => t.storageChilled,
      'frozen' => t.storageFrozen,
      _ => t.storageAmbient,
    };

IconData storageIcon(String s) => switch (s) {
      'chilled' => Icons.kitchen_outlined,
      'frozen' => Icons.ac_unit_rounded,
      _ => Icons.wb_sunny_outlined,
    };

IconData ingredientKindIcon(String k) => switch (k) {
      'beverage' => Icons.local_drink_outlined,
      'packaging' => Icons.inventory_outlined,
      'semi_finished' => Icons.blender_outlined,
      'consumable' => Icons.cleaning_services_outlined,
      _ => Icons.eco_outlined,
    };

/// « 12,5 » ou « 12.5 » → 12.5 ; 4 décimales au plus ; null si invalide.
double? parseQty(String text, {bool allowNegative = false}) {
  final s = text.trim().replaceAll(RegExp(r'[\s  ]'), '').replaceAll(',', '.');
  final re = allowNegative ? RegExp(r'^-?\d+(\.\d{1,4})?$') : RegExp(r'^\d+(\.\d{1,4})?$');
  if (!re.hasMatch(s)) return null;
  return double.parse(s);
}

String formatQty(BuildContext context, double q) =>
    NumberFormat.decimalPatternDigits(locale: Localizations.localeOf(context).toString(), decimalDigits: 3)
        .format(q)
        .replaceAll(RegExp(r'([.,]\d*?)0+$'), r'$1')
        .replaceAll(RegExp(r'[.,]$'), '');

/// Unités compatibles avec l'unité de stock d'un ingrédient (même nature).
List<Unit> compatibleUnits(List<Unit> all, String stockUnit) {
  final dim = all.firstWhere((u) => u.code == stockUnit, orElse: () => all.first).dimension;
  return all.where((u) => u.dimension == dim).toList();
}

class MovementResult {
  MovementResult(this.quantity, this.unit, this.unitCost, this.reason, this.toLocationId, {this.batch, this.expiresOn});
  final String? batch;
  final DateTime? expiresOn;
  final double quantity;
  final String unit;
  final double unitCost;
  final String? reason;
  final String? toLocationId;
}

/// Saisie d'un mouvement : quantité + unité ; coût pour une entrée ; motif
/// pour une perte, un repas du personnel, un retour ou un ajustement ;
/// emplacement d'arrivée pour un transfert.
class MovementDialog extends StatefulWidget {
  const MovementDialog({
    super.key,
    required this.title,
    required this.kind,
    required this.ingredient,
    required this.units,
    required this.currency,
    this.locations = const [],
    this.fromLocationId,
  });

  final String title;
  final String kind; // receipt, opening, waste, staff_meal, return, adjustment, transfer, production
  final Ingredient ingredient;
  final List<Unit> units;
  final String currency;
  final List<StockLocation> locations;
  final String? fromLocationId;

  @override
  State<MovementDialog> createState() => _MovementDialogState();
}

class _MovementDialogState extends State<MovementDialog> {
  final _form = GlobalKey<FormState>();
  final _qty = TextEditingController();
  final _cost = TextEditingController();
  final _reason = TextEditingController();
  final _batch = TextEditingController();
  late String _unit = widget.ingredient.unitCode;
  String? _to;

  /// Date limite proposée d'après la durée de conservation de l'article.
  late DateTime? _expires = widget.ingredient.shelfLifeDays == null
      ? null
      : DateTime.now().add(Duration(days: widget.ingredient.shelfLifeDays!));

  bool get _withCost => widget.kind == 'receipt' || widget.kind == 'opening';
  bool get _withReason => const ['waste', 'staff_meal', 'return', 'adjustment'].contains(widget.kind);

  @override
  void dispose() {
    _qty.dispose();
    _cost.dispose();
    _reason.dispose();
    _batch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final units = widget.kind == 'production' ? [widget.units.firstWhere((u) => u.code == widget.ingredient.unitCode)] : compatibleUnits(widget.units, widget.ingredient.unitCode);
    final targets = widget.locations.where((l) => l.active && l.id != widget.fromLocationId).toList();
    return AlertDialog(
      title: Text('${widget.title} · ${widget.ingredient.name}'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _form,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _qty,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: InputDecoration(
                    labelText: widget.kind == 'adjustment' ? t.adjustmentQuantity : t.quantity,
                  ),
                  validator: (v) {
                    final q = parseQty(v ?? '', allowNegative: widget.kind == 'adjustment');
                    return (q == null || q == 0) ? t.errorInvalidQuantity : null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _unit,
                items: [for (final u in units) DropdownMenuItem(value: u.code, child: Text(unitLabel(t, u.code)))],
                onChanged: (v) => setState(() => _unit = v ?? _unit),
              ),
            ]),
            if (_withCost)
              TextFormField(
                controller: _cost,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: t.unitCost(unitLabel(t, _unit)), suffixText: widget.currency),
                validator: (v) => (v ?? '').trim().isEmpty || parseQty(v!) != null ? null : t.errorInvalidAmount,
              ),
            if (_withCost)
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _batch,
                    maxLength: 60,
                    decoration: InputDecoration(labelText: t.batchNumber, counterText: ''),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _expires ?? DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (d != null) setState(() => _expires = d);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: t.expiryDate,
                        suffixIcon: _expires == null
                            ? const Icon(Icons.event_outlined)
                            : IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => setState(() => _expires = null)),
                      ),
                      child: Text(_expires == null ? '—' : DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(_expires!)),
                    ),
                  ),
                ),
              ]),
            if (widget.kind == 'transfer')
              DropdownButtonFormField<String>(
                initialValue: _to,
                decoration: InputDecoration(labelText: t.toLocation),
                items: [for (final l in targets) DropdownMenuItem(value: l.id, child: Text(l.name))],
                onChanged: (v) => setState(() => _to = v),
                validator: (v) => v == null ? t.fieldRequired : null,
              ),
            if (_withReason || widget.kind == 'transfer')
              TextFormField(
                controller: _reason,
                maxLength: 300,
                decoration: InputDecoration(labelText: _withReason ? t.reason : t.descriptionOptional),
                validator: (v) => _withReason && (v ?? '').trim().length < 3 ? t.errorReasonRequired : null,
              ),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            Navigator.pop(
              context,
              MovementResult(
                parseQty(_qty.text, allowNegative: widget.kind == 'adjustment')!,
                _unit,
                parseQty(_cost.text) ?? 0,
                _reason.text.trim().isEmpty ? null : _reason.text.trim(),
                _to,
                batch: _batch.text.trim().isEmpty ? null : _batch.text.trim(),
                expiresOn: _withCost ? _expires : null,
              ),
            );
          },
          child: Text(t.confirm),
        ),
      ],
    );
  }
}

class IngredientDialog extends StatefulWidget {
  const IngredientDialog({super.key, required this.units, this.ingredient});
  final List<Unit> units;
  final Ingredient? ingredient;

  @override
  State<IngredientDialog> createState() => _IngredientDialogState();
}

class _IngredientDialogState extends State<IngredientDialog> {
  late final _name = TextEditingController(text: widget.ingredient?.name);
  late String _kind = widget.ingredient?.kind ?? 'raw';
  late String _unit = widget.ingredient?.unitCode ?? 'kg';
  late bool _active = widget.ingredient?.active ?? true;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AlertDialog(
      title: Text(widget.ingredient == null ? t.newIngredient : t.edit),
      content: SizedBox(
        width: 420,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: _name,
            autofocus: true,
            maxLength: 120,
            decoration: InputDecoration(labelText: t.name, hintText: t.ingredientExamples),
          ),
          DropdownButtonFormField<String>(
            initialValue: _kind,
            decoration: InputDecoration(labelText: t.ingredientKind),
            items: [for (final k in ingredientKinds) DropdownMenuItem(value: k, child: Text(ingredientKindLabel(t, k)))],
            onChanged: (v) => setState(() => _kind = v ?? _kind),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _unit,
            decoration: InputDecoration(labelText: t.stockUnit),
            items: [for (final u in widget.units) DropdownMenuItem(value: u.code, child: Text(unitLabel(t, u.code)))],
            onChanged: (v) => setState(() => _unit = v ?? _unit),
          ),
          if (widget.ingredient != null)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.active),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(
          onPressed: () {
            if (_name.text.trim().isEmpty) return;
            Navigator.pop(context, (_name.text.trim(), _kind, _unit, _active));
          },
          child: Text(t.save),
        ),
      ],
    );
  }
}
