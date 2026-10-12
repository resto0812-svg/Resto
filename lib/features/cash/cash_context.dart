import 'package:flutter/material.dart';

import '../../data/api.dart';
import '../../data/cash_api.dart';
import '../../ui/branch_scope.dart';
import '../../ui/common.dart';
import '../../ui/theme.dart';

/// Données communes du module Caisse d'un établissement.
class CashContext extends ChangeNotifier {
  CashContext(this.api, this.scope);
  final Api api;
  final BranchContext scope;

  List<CashRegister> registers = const [];
  String? registerId;
  List<PaymentMethod> methods = const [];
  List<Denomination> denominations = const [];
  Map<String, String> staff = const {};
  Map<String, String> tableLabels = const {};
  bool loaded = false;
  Object? error;

  CashApi get cash => api.cash;
  CashRegister? get register => registers.where((r) => r.id == registerId).firstOrNull;
  List<PaymentMethod> get branchMethods => methods.where((m) => m.availableIn(scope.branchId)).toList();
  String staffName(String? id) => id == null ? '—' : (staff[id] ?? '—');
  String registerName(String id) => registers.where((r) => r.id == id).firstOrNull?.name ?? '—';

  Future<void> load() async {
    try {
      final r = await Future.wait<dynamic>([
        cash.registers(scope.branchId),
        cash.paymentMethods(scope.orgId),
        cash.denominations(scope.currency),
        cash.staff(scope.orgId),
        api.floor(scope.branchId),
      ]);
      registers = r[0] as List<CashRegister>;
      methods = r[1] as List<PaymentMethod>;
      denominations = r[2] as List<Denomination>;
      staff = r[3] as Map<String, String>;
      tableLabels = {
        for (final a in r[4] as List)
          for (final tb in a.tables) tb.id as String: tb.label as String,
      };
      final active = registers.where((x) => x.active).toList();
      if (registerId == null || !active.any((x) => x.id == registerId)) registerId = active.firstOrNull?.id;
      loaded = true;
      error = null;
    } catch (e) {
      error = e;
    }
    notifyListeners();
  }

  void selectRegister(String id) {
    registerId = id;
    notifyListeners();
  }
}

/// Comptage billet par billet : nombre de chaque coupure, total en direct.
/// Sans coupures connues pour la monnaie : saisie libre du montant.
class DenominationCounter extends StatelessWidget {
  const DenominationCounter({super.key, required this.denominations, required this.counts, required this.money, required this.onChanged});
  final List<Denomination> denominations;
  final Map<int, int> counts;
  final String Function(int) money;
  final VoidCallback onChanged;

  static int total(Map<int, int> counts) => counts.entries.fold(0, (a, e) => a + e.key * e.value);

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    Widget group(String title, Iterable<Denomination> list) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Text(title, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final d in list)
              Container(
                width: 168,
                padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: (counts[d.valueMinor] ?? 0) > 0 ? RestoColors.primary : theme.colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(d.isNote ? Icons.money_rounded : Icons.toll_rounded, size: 18, color: RestoColors.primaryDeep),
                    const SizedBox(width: 6),
                    Expanded(child: Text(money(d.valueMinor), style: theme.textTheme.labelLarge)),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: (counts[d.valueMinor] ?? 0) > 0
                          ? () {
                              counts[d.valueMinor] = (counts[d.valueMinor] ?? 0) - 1;
                              onChanged();
                            }
                          : null,
                      icon: const Icon(Icons.remove, size: 18),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final v = await _askCount(context, counts[d.valueMinor] ?? 0);
                        if (v != null) {
                          counts[d.valueMinor] = v;
                          onChanged();
                        }
                      },
                      child: SizedBox(
                        width: 30,
                        child: Text('${counts[d.valueMinor] ?? 0}', textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        counts[d.valueMinor] = (counts[d.valueMinor] ?? 0) + 1;
                        onChanged();
                      },
                      icon: const Icon(Icons.add, size: 18),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        group(t.notesLabel, denominations.where((d) => d.isNote)),
        if (denominations.any((d) => !d.isNote)) group(t.coinsLabel, denominations.where((d) => !d.isNote)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(gradient: RestoColors.brandGradient, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Expanded(
                child: Text(t.countedTotal, style: theme.textTheme.titleMedium?.copyWith(color: RestoColors.onPrimary)),
              ),
              Text(money(total(counts)), style: theme.textTheme.headlineSmall?.copyWith(color: RestoColors.onPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  static Future<int?> _askCount(BuildContext context, int current) {
    final c = TextEditingController(text: '$current');
    return showDialog<int>(
      context: context,
      builder: (d) => AlertDialog(
        content: TextField(controller: c, autofocus: true, keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: Text(d.t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(d, int.tryParse(c.text.trim())), child: Text(d.t.confirm)),
        ],
      ),
    ).whenComplete(c.dispose);
  }
}

/// Carte d'indicateur.
class CashKpi extends StatelessWidget {
  const CashKpi({super.key, required this.label, required this.value, this.icon, this.color, this.width = 200});
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: (color ?? RestoColors.primary).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: color ?? RestoColors.primaryDeep),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(value, style: theme.textTheme.titleLarge?.copyWith(color: color)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
