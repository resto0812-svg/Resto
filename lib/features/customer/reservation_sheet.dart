import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import '../menus/menu_widgets.dart' show uuidV4;
import '../service/service_labels.dart' show dayLabel, hm;
import 'customer_shell.dart';

/// Demande de réservation par le client : date, heure, nombre de personnes,
/// coordonnées (pré-remplies depuis son profil). Le restaurant confirme.
/// Depuis l'onglet Tables : créneau, groupe et tables déjà choisis ([tables] :
/// identifiant et nom de chaque table, bloquées dès la demande).
Future<bool> requestTableReservation(BuildContext context,
    {required String branchId, required String restaurantName, DateTime? start, int? party, List<(String, String)> tables = const []}) async {
  if (!await ensureCustomerSignedIn(context) || !context.mounted) return false;
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ReservationSheet(branchId: branchId, restaurantName: restaurantName, start: start, party: party, tables: tables),
  );
  return ok == true;
}

class _ReservationSheet extends StatefulWidget {
  const _ReservationSheet({required this.branchId, required this.restaurantName, this.start, this.party, this.tables = const []});
  final String branchId;
  final String restaurantName;
  final DateTime? start;
  final int? party;
  final List<(String, String)> tables;

  @override
  State<_ReservationSheet> createState() => _ReservationSheetState();
}

class _ReservationSheetState extends State<_ReservationSheet> {
  final _form = GlobalKey<FormState>();
  late DateTime _start = widget.start ?? _nextSlot();
  late int _party = widget.party ?? 2;
  int _maxParty = 12;
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _note = TextEditingController();
  final _clientId = uuidV4();

  static DateTime _nextSlot() {
    final n = DateTime.now().add(const Duration(minutes: 60));
    return DateTime(n.year, n.month, n.day, n.hour, n.minute < 30 ? 30 : 0).add(Duration(hours: n.minute < 30 ? 0 : 1));
  }

  @override
  void initState() {
    super.initState();
    final api = AppScope.read(context).api!.customer;
    api
        .profile()
        .then((p) {
          if (!mounted) return;
          if (_name.text.isEmpty) _name.text = p.fullName ?? '';
          if (_phone.text.isEmpty) _phone.text = p.phone ?? '';
        })
        .catchError((_) {});
    api
        .reservationSettings(widget.branchId)
        .then((s) {
          final max = (s?['max_party_size'] as num?)?.toInt();
          if (mounted && max != null && max > 0) setState(() => _maxParty = max);
        })
        .catchError((_) {});
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _send() async {
    final t = context.t;
    if (!_form.currentState!.validate()) return;
    if (_start.isBefore(DateTime.now().add(const Duration(minutes: 15)))) {
      showInfo(context, t.scheduleTooSoon);
      return;
    }
    try {
      await AppScope.read(context).api!.customer.requestReservation(
        branchId: widget.branchId,
        startsAt: _start,
        partySize: _party,
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        clientId: _clientId,
        tableIds: [for (final tb in widget.tables) tb.$1],
      );
      if (!mounted) return;
      showInfo(context, t.reservationSentHint);
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.reserveAt(widget.restaurantName), style: serifTitle(context, size: 24)),
              if (widget.tables.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 6, children: [
                  for (final tb in widget.tables)
                    StatusPill(label: t.tableLabelChip(tb.$2), color: StatusColors.free, icon: Icons.table_restaurant_rounded),
                ]),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _PickTile(
                      icon: Icons.calendar_today_rounded,
                      label: t.dateLabel,
                      value: dayLabel(context, _start),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _start,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (d != null) setState(() => _start = DateTime(d.year, d.month, d.day, _start.hour, _start.minute));
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PickTile(
                      icon: Icons.schedule_rounded,
                      label: t.timeLabel,
                      value: hm(context, _start),
                      onTap: () async {
                        final p = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_start));
                        if (p != null) setState(() => _start = DateTime(_start.year, _start.month, _start.day, p.hour, p.minute));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SoftCard(
                padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                child: Row(
                  children: [
                    const Icon(Icons.groups_2_outlined, color: RestoColors.primaryDeep),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(t.guestsLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    IconButton(
                      onPressed: _party > 1 ? () => setState(() => _party--) : null,
                      icon: const Icon(Icons.remove_circle_outline_rounded, color: RestoColors.primaryDeep),
                    ),
                    SizedBox(
                      width: 34,
                      child: Text('$_party', textAlign: TextAlign.center, style: serifTitle(context, size: 22)),
                    ),
                    IconButton(
                      onPressed: _party < _maxParty ? () => setState(() => _party++) : null,
                      icon: const Icon(Icons.add_circle_outline_rounded, color: RestoColors.primaryDeep),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                maxLength: 120,
                decoration: InputDecoration(labelText: t.yourName, counterText: ''),
                validator: (v) => (v ?? '').trim().isEmpty ? t.fieldRequired : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phone,
                maxLength: 40,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: t.phone, counterText: ''),
                validator: (v) => (v ?? '').trim().length < 6 ? t.fieldRequired : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _note,
                maxLength: 500,
                decoration: InputDecoration(labelText: t.reservationNoteLabel, hintText: t.reservationNoteHint, counterText: ''),
              ),
              const SizedBox(height: 16),
              GoldButton(label: t.reserveTable, icon: Icons.event_available_rounded, onPressed: _send),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickTile extends StatelessWidget {
  const _PickTile({required this.icon, required this.label, required this.value, required this.onTap});
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SoftCard(
    padding: EdgeInsets.zero,
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: RestoColors.primaryDeep, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: RestoColors.muted, fontSize: 11.5)),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
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
