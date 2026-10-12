import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../app_state.dart';
import '../../data/stock_api.dart';
import '../../pdf/stock_pdf.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import 'stock_screen.dart';
import 'stock_widgets.dart';

/// Familles de mouvements pour les filtres.
const movementGroups = <String, List<String>>{
  'in': ['receipt', 'opening', 'production_in', 'transfer_in'],
  'out': ['sale', 'staff_meal', 'production_out', 'return'],
  'waste': ['waste'],
  'transfer': ['transfer_in', 'transfer_out'],
  'adjust': ['adjustment', 'inventory'],
};

/// Journal des mouvements d'une période : filtres, totaux, export PDF.
class MovementsTab extends StatefulWidget {
  const MovementsTab({super.key, required this.stock});
  final StockContext stock;

  @override
  State<MovementsTab> createState() => _MovementsTabState();
}

class _MovementsTabState extends State<MovementsTab> {
  late DateTimeRange _range = DateTimeRange(start: DateTime.now().subtract(const Duration(days: 6)), end: DateTime.now());
  String _group = 'all';
  String _query = '';
  late Future<List<StockMovement>> _data = _load();

  StockContext get s => widget.stock;

  Future<List<StockMovement>> _load() =>
      AppScope.read(context).api!.stock.movementsBetween(s.branch.id!, _range.start, _range.end, kinds: movementGroups[_group]);

  Future<void> _pickRange() async {
    final r = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: DateTime.now().subtract(const Duration(days: 730)),
      lastDate: DateTime.now(),
    );
    if (r != null) {
      setState(() {
        _range = r;
        _data = _load();
      });
    }
  }

  Future<void> _pdf(List<StockMovement> list) async {
    final t = context.t;
    final bytes = await movementsPdf(
      StockDocContext(t: t, locale: Localizations.localeOf(context).toString(), minorUnit: s.minorUnit, branch: s.branch),
      list,
      _range.start,
      _range.end,
      title: _group == 'waste' ? t.wasteReportTitle : t.movementsReportTitle,
    );
    final f = DateFormat('yyyyMMdd');
    await Printing.sharePdf(bytes: bytes, filename: 'mouvements-${f.format(_range.start)}-${f.format(_range.end)}.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    final locale = Localizations.localeOf(context).toString();
    final day = DateFormat.yMMMd(locale);
    final fmt = DateFormat.yMd(locale).add_Hm();
    return FutureBuilder(
      future: _data,
      builder: (context, snap) {
        final all = snap.data ?? const <StockMovement>[];
        final q = _query.trim().toLowerCase();
        final list = all.where((m) => q.isEmpty || m.ingredientName.toLowerCase().contains(q)).toList();
        final inValue = list.where((m) => m.quantity > 0).fold<double>(0, (a, m) => a + m.value);
        final outValue = list.where((m) => m.quantity < 0).fold<double>(0, (a, m) => a - m.value);
        return ListView(padding: EdgeInsets.fromLTRB(side, 6, side, 40), children: [
          Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
            ActionChip(
              avatar: const Icon(Icons.date_range_rounded, size: 18),
              label: Text('${day.format(_range.start)} – ${day.format(_range.end)}'),
              onPressed: _pickRange,
            ),
            PillBar<String>(
              dense: true,
              items: [
                PillItem('all', t.allFilter),
                PillItem('in', t.entriesFilter, icon: Icons.south_west_rounded),
                PillItem('out', t.consumptionLabel, icon: Icons.restaurant_outlined),
                PillItem('waste', t.wasteLabel, icon: Icons.delete_outline_rounded),
                PillItem('transfer', t.transfersFilter, icon: Icons.swap_horiz_rounded),
                PillItem('adjust', t.adjustmentsFilter, icon: Icons.tune_rounded),
              ],
              selected: _group,
              onSelected: (v) => setState(() {
                _group = v;
                _data = _load();
              }),
            ),
            SizedBox(
              width: 220,
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(isDense: true, fillColor: Colors.white, hintText: t.searchArticle, prefixIcon: const Icon(Icons.search_rounded, size: 20)),
              ),
            ),
            OutlinedButton.icon(
              onPressed: list.isEmpty ? null : () => _pdf(list),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: Text(t.exportPdf),
            ),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 10, children: [
            CounterTile(icon: Icons.swap_vert_rounded, value: '${list.length}', label: t.movementsTab, highlight: true),
            CounterTile(icon: Icons.south_west_rounded, value: s.money(context, inValue), label: t.entriesFilter),
            CounterTile(icon: Icons.north_east_rounded, value: s.money(context, outValue), label: t.exitsLabel),
          ]),
          const SizedBox(height: 12),
          if (snap.hasError)
            Center(child: TextButton(onPressed: () => setState(() => _data = _load()), child: Text(t.retry)))
          else if (!snap.hasData)
            const Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator()))
          else if (list.isEmpty)
            EmptyState(icon: Icons.swap_vert_rounded, title: t.noMovementsPeriod)
          else
            SoftCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(children: [
                for (final (i, m) in list.indexed) ...[
                  if (i > 0) const Divider(height: 1, color: RestoColors.line),
                  ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: (m.quantity < 0 ? const Color(0xFFC0392B) : const Color(0xFF2E9E5B)).withValues(alpha: 0.12),
                      child: Icon(m.quantity < 0 ? Icons.north_east_rounded : Icons.south_west_rounded,
                          size: 16, color: m.quantity < 0 ? const Color(0xFFC0392B) : const Color(0xFF2E9E5B)),
                    ),
                    title: Text('${movementLabel(t, m.kind)} · ${m.ingredientName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text([fmt.format(m.createdAt.toLocal()), m.locationName, ?m.reason, if (m.batch != null) t.batchShort(m.batch!)].join(' · ')),
                    trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(
                        '${m.quantity > 0 ? '+' : ''}${formatQty(context, m.quantity)} ${unitLabel(t, m.unitCode)}',
                        style: TextStyle(fontWeight: FontWeight.w700, color: m.quantity < 0 ? const Color(0xFFC0392B) : const Color(0xFF2E9E5B)),
                      ),
                      if (m.unitCost > 0) Text(s.money(context, m.value.abs()), style: const TextStyle(fontSize: 11.5, color: RestoColors.muted)),
                    ]),
                  ),
                ],
              ]),
            ),
        ]);
      },
    );
  }
}
