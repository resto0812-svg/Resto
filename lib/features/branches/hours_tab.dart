import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/models.dart';
import '../../ui/common.dart';

/// Horaires d'ouverture : plusieurs plages par jour ; une plage dont la
/// fermeture précède l'ouverture se termine le lendemain.
class HoursTab extends StatelessWidget {
  const HoursTab({super.key, required this.branchId, required this.canEdit});
  final String branchId;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final api = AppScope.of(context).api!;
    return Loader<List<OpeningHour>>(
      load: () => api.openingHours(branchId),
      builder: (context, hours, reload) => _HoursEditor(
        key: ValueKey(hours),
        branchId: branchId,
        canEdit: canEdit,
        initial: hours,
        onSaved: reload,
      ),
    );
  }
}

class _HoursEditor extends StatefulWidget {
  const _HoursEditor(
      {super.key, required this.branchId, required this.canEdit, required this.initial, required this.onSaved});
  final String branchId;
  final bool canEdit;
  final List<OpeningHour> initial;
  final VoidCallback onSaved;

  @override
  State<_HoursEditor> createState() => _HoursEditorState();
}

class _HoursEditorState extends State<_HoursEditor> with AutomaticKeepAliveClientMixin {
  late final List<OpeningHour> _hours = [...widget.initial];

  @override
  bool get wantKeepAlive => true;

  String _hhmm(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  TimeOfDay _parse(String s) => TimeOfDay(hour: int.parse(s.substring(0, 2)), minute: int.parse(s.substring(3, 5)));

  Future<void> _addSlot(int weekday) async {
    final t = context.t;
    final opens = await showTimePicker(
        context: context, helpText: t.opensAt, initialTime: const TimeOfDay(hour: 9, minute: 0));
    if (opens == null || !mounted) return;
    final closes = await showTimePicker(
        context: context, helpText: t.closesAt, initialTime: const TimeOfDay(hour: 22, minute: 0));
    if (closes == null) return;
    if (closes == opens) {
      if (mounted) showInfo(context, t.errorInvalidHours);
      return;
    }
    setState(() {
      _hours.add(OpeningHour(weekday, _hhmm(opens), _hhmm(closes)));
      _hours.sort((a, b) => a.weekday != b.weekday ? a.weekday - b.weekday : a.opensAt.compareTo(b.opensAt));
    });
  }

  Future<void> _save() async {
    try {
      await AppScope.read(context).api!.setOpeningHours(widget.branchId, _hours);
      if (!mounted) return;
      showInfo(context, context.t.saved);
      widget.onSaved();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final t = context.t;
    return ListView(padding: const EdgeInsets.all(16), children: [
      for (var day = 1; day <= 7; day++)
        FormWidth(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(width: 110, child: Text(weekdayName(t, day), style: Theme.of(context).textTheme.titleSmall)),
                Expanded(
                  child: Wrap(spacing: 8, runSpacing: 4, children: [
                    for (final h in _hours.where((h) => h.weekday == day))
                      InputChip(
                        label: Text(
                          '${_parse(h.opensAt).format(context)} – ${_parse(h.closesAt).format(context)}'
                          '${h.closesAt.compareTo(h.opensAt) < 0 ? ' (${t.nextDay})' : ''}',
                        ),
                        onDeleted: widget.canEdit ? () => setState(() => _hours.remove(h)) : null,
                      ),
                    if (_hours.every((h) => h.weekday != day)) Chip(label: Text(t.closed)),
                  ]),
                ),
                if (widget.canEdit)
                  IconButton(tooltip: t.addSlot, icon: const Icon(Icons.add), onPressed: () => _addSlot(day)),
              ]),
            ),
          ),
        ),
      const SizedBox(height: 16),
      if (widget.canEdit) FormWidth(child: BusyButton(label: t.save, onPressed: _save)),
    ]);
  }
}
