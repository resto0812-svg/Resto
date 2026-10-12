import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/models.dart';
import '../../ui/common.dart';
import '../../ui/theme.dart';
import '../menus/menu_widgets.dart';
import 'floor_plan.dart';
import 'service_hub.dart';
import 'service_labels.dart';

/// Nouvelle commande en une seule fiche : le type, puis la table ou le client.
/// Renvoie l'identifiant de la commande créée (ou de celle déjà ouverte sur la table).
class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key, required this.hub, this.table, this.channel});
  final ServiceHub hub;
  final DiningTable? table;
  final String? channel;

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _form = GlobalKey<FormState>();
  late String _channel = widget.channel ?? 'dine_in';
  late DiningTable? _table = widget.table;
  late int _guests = widget.table?.seats.clamp(1, 4) ?? 2;
  bool _byPhone = false;
  bool _later = false;
  TimeOfDay? _time;
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _instructions = TextEditingController();
  final _note = TextEditingController();
  final _clientId = uuidV4();
  bool _busy = false;
  bool _tried = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _address, _instructions, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  DateTime? get _scheduled {
    if (!_later || _time == null) return null;
    final now = DateTime.now();
    var d = DateTime(now.year, now.month, now.day, _time!.hour, _time!.minute);
    if (d.isBefore(now.subtract(const Duration(minutes: 30)))) d = d.add(const Duration(days: 1));
    return d;
  }

  Future<void> _submit() async {
    setState(() => _tried = true);
    if (_channel == 'dine_in' && _table == null) return;
    if (!_form.currentState!.validate()) return;
    if (_later && _time == null) return;
    final hub = widget.hub;
    final existing = _channel == 'dine_in'
        ? hub.orders.where((o) => o.isOpen && o.tableId == _table!.id).firstOrNull
        : null;
    if (existing != null) {
      Navigator.pop(context, existing.id);
      return;
    }
    setState(() => _busy = true);
    try {
      String? v(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
      final id = await AppScope.read(context).api!.orders.create(
            branchId: hub.scope.branchId,
            channel: _channel,
            tableId: _channel == 'dine_in' ? _table!.id : null,
            guests: _channel == 'dine_in' ? _guests : null,
            source: _byPhone && _channel != 'dine_in' ? 'phone' : 'staff',
            customerName: v(_name),
            phone: v(_phone),
            address: _channel == 'delivery' ? v(_address) : null,
            instructions: _channel == 'delivery' ? v(_instructions) : null,
            scheduledFor: _channel == 'dine_in' ? null : _scheduled,
            note: v(_note),
            clientId: _clientId,
          );
      if (mounted) Navigator.pop(context, id);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final hub = widget.hub;
    final infos = tableInfos(hub.areas, hub.orders, hub.reservations);
    final scope = hub.scope;

    Widget typeTile(String value, String label, String hint) {
      final selected = _channel == value;
      final scheme = theme.colorScheme;
      return Expanded(
        child: Material(
          color: selected ? scheme.primaryContainer : scheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: selected ? scheme.primary : scheme.outlineVariant, width: selected ? 2 : 1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _channel = value),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
              child: Column(children: [
                Icon(channelIcon(value), size: 32, color: selected ? scheme.primary : scheme.onSurfaceVariant),
                const SizedBox(height: 6),
                Text(label, textAlign: TextAlign.center, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(hint, textAlign: TextAlign.center, style: theme.textTheme.bodySmall, maxLines: 2),
              ]),
            ),
          ),
        ),
      );
    }

    final tableSection = <Widget>[
      Text(t.chooseTable, style: theme.textTheme.titleSmall),
      const SizedBox(height: 8),
      if (hub.allTables.where((x) => x.active).isEmpty) Text(t.noTablesYet),
      for (final a in hub.areas.where((a) => a.active && a.tables.any((x) => x.active))) ...[
        Padding(padding: const EdgeInsets.only(top: 6, bottom: 6), child: Text(a.name, style: theme.textTheme.labelLarge)),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final tb in a.tables.where((x) => x.active))
            Builder(builder: (context) {
              final info = infos[tb.id]!;
              final color = tableColor(info.kind);
              final selected = _table?.id == tb.id;
              return ChoiceChip(
                avatar: Icon(Icons.circle, size: 10, color: color),
                label: Text(info.order != null ? '${tb.label} · ${t.tableOccupied}' : '${tb.label} · ${tb.seats}'),
                selected: selected,
                onSelected: (_) => setState(() {
                  _table = tb;
                  _guests = tb.seats.clamp(1, 4);
                }),
              );
            }),
        ]),
      ],
      if (_tried && _table == null)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(t.chooseTable, style: TextStyle(color: theme.colorScheme.error)),
        ),
      if (_table != null) ...[
        Builder(builder: (context) {
          final info = infos[_table!.id]!;
          final r = info.current ?? info.next;
          if (info.order != null) {
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(t.tableHasOrder, style: TextStyle(color: StatusColors.occupied, fontWeight: FontWeight.w600)),
            );
          }
          if (r == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(children: [
              const Icon(Icons.event_rounded, size: 18, color: StatusColors.reserved),
              const SizedBox(width: 6),
              Expanded(
                child: Text(t.tableReservationWarning(hm(context, r.startsAt), r.customerName, r.partySize),
                    style: const TextStyle(color: StatusColors.reserved, fontWeight: FontWeight.w600)),
              ),
            ]),
          );
        }),
        const SizedBox(height: 16),
        Row(children: [
          Text(t.guestsLabel, style: theme.textTheme.titleSmall),
          const Spacer(),
          IconButton.outlined(onPressed: _guests > 1 ? () => setState(() => _guests--) : null, icon: const Icon(Icons.remove)),
          SizedBox(width: 48, child: Text('$_guests', textAlign: TextAlign.center, style: theme.textTheme.titleLarge)),
          IconButton.outlined(onPressed: _guests < 200 ? () => setState(() => _guests++) : null, icon: const Icon(Icons.add)),
        ]),
      ],
    ];

    final phoneRequired = _channel == 'delivery' || _byPhone;
    final customerSection = <Widget>[
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: const Icon(Icons.phone_in_talk_rounded),
        title: Text(t.receivedByPhone),
        value: _byPhone,
        onChanged: (v) => setState(() => _byPhone = v),
      ),
      TextFormField(
        controller: _name,
        maxLength: 120,
        decoration: InputDecoration(labelText: _channel == 'delivery' ? t.customerName : t.customerNameOptional, counterText: ''),
        validator: (v) => _channel == 'delivery' && (v ?? '').trim().isEmpty ? t.fieldRequired : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _phone,
        maxLength: 40,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(labelText: phoneRequired ? t.phone : t.phoneOptional, counterText: ''),
        validator: (v) => phoneRequired && (v ?? '').trim().length < 6 ? t.fieldRequired : null,
      ),
      if (_channel == 'delivery') ...[
        const SizedBox(height: 12),
        TextFormField(
          controller: _address,
          maxLength: 500,
          maxLines: 2,
          decoration: InputDecoration(labelText: t.deliveryAddress, hintText: t.deliveryAddressHint, counterText: ''),
          validator: (v) => (v ?? '').trim().length < 3 ? t.fieldRequired : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _instructions,
          maxLength: 500,
          decoration: InputDecoration(labelText: t.deliveryInstructions, hintText: t.deliveryInstructionsHint, counterText: ''),
        ),
        if (scope.branch.deliveryFeeMinor > 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('${t.deliveryFee} : ${scope.money(context, scope.branch.deliveryFeeMinor)}', style: theme.textTheme.bodySmall),
          ),
      ],
      const SizedBox(height: 16),
      Text(_channel == 'delivery' ? t.deliveryTime : t.pickupTime, style: theme.textTheme.titleSmall),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        ChoiceChip(label: Text(t.asap), selected: !_later, onSelected: (_) => setState(() => _later = false)),
        ChoiceChip(
          label: Text(_later && _time != null ? t.atTime(_time!.format(context)) : t.atFixedTime),
          selected: _later,
          onSelected: (_) async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _time ?? TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 45))),
            );
            if (picked != null) {
              setState(() {
                _later = true;
                _time = picked;
              });
            }
          },
        ),
      ]),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(t.newOrder)),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
          FormWidth(
            maxWidth: 760,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(t.orderTypeQuestion, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              Row(children: [
                typeTile('dine_in', t.channelDineIn, t.dineInHint),
                const SizedBox(width: 10),
                typeTile('takeaway', t.channelTakeaway, t.takeawayHint),
                const SizedBox(width: 10),
                typeTile('delivery', t.channelDelivery, t.deliveryHint),
              ]),
              const SizedBox(height: 24),
              if (_channel == 'dine_in') ...tableSection else ...customerSection,
              const SizedBox(height: 16),
              TextFormField(
                controller: _note,
                maxLength: 500,
                decoration: InputDecoration(labelText: t.orderNote, hintText: t.orderNoteHint, counterText: ''),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _busy ? null : _submit,
                icon: _busy
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.restaurant_menu_rounded),
                label: Text(t.continueToMenu),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
