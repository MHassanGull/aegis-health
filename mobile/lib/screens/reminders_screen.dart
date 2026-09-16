import 'package:flutter/material.dart';

import '../core/notifications.dart';
import '../core/theme.dart';
import '../data/reminder.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});
  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Reminder> _items = [];
  bool _loading = true;
  bool _granted = true;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    _granted = await NotificationService.instance.requestPermission();
    _items = await ReminderStore.load();
    if (mounted) setState(() => _loading = false);
  }

  int _nextId() =>
      (_items.isEmpty ? 1 : _items.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1);

  Future<void> _sync() async {
    await ReminderStore.saveAndSync(_items);
    if (mounted) setState(() {});
  }

  Future<void> _toggle(Reminder r, bool v) async {
    r.enabled = v;
    await _sync();
  }

  Future<void> _delete(Reminder r) async {
    await NotificationService.instance.cancel(r.id);
    _items.removeWhere((x) => x.id == r.id);
    await _sync();
  }

  Future<void> _addFlow() async {
    final preset = await showModalBottomSheet<ReminderPreset>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PresetPicker(),
    );
    if (preset == null) return;

    String title = preset.title;
    String body = preset.body;
    if (preset.type == 'custom') {
      final custom = await _askCustom();
      if (custom == null) return;
      title = custom;
      body = 'Reminder: $custom';
    }
    if (!mounted) return;
    final hours = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _IntervalPicker(preset.defaultMinutes),
    );
    if (hours == null) return;

    final reminder = Reminder(
      id: _nextId(),
      type: preset.type,
      title: title,
      body: body,
      everyMinutes: hours,
    );
    _items.add(reminder);
    await _sync();
    // Instant confirmation so you can SEE it's active (the real reminder then
    // repeats on schedule).
    await NotificationService.instance.showNow(
      900000 + reminder.id,
      'Reminder set ✓',
      '$title, I’ll remind you ${reminder.everyLabel.toLowerCase()}.',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reminder set, ${reminder.everyLabel.toLowerCase()}')));
    }
  }

  Future<String?> _askCustom() {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Custom reminder'),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Check blood pressure'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, c.text.trim()),
              child: const Text('Next')),
        ],
      ),
    ).then((v) => (v == null || v.isEmpty) ? null : v);
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addFlow,
        backgroundColor: AppTheme.green,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add', style: TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          // The header is item 0; reminder cards below it are built lazily,
          // so a long list costs no more to open than a short one.
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(AppTheme.gutter, 8,
                  AppTheme.gutter, 96),
              itemCount: (_items.isEmpty ? 1 : _items.length) + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_granted) _permissionBanner(p),
                      Text('Stay healthy on schedule',
                          style: Theme.of(context).textTheme.displaySmall),
                      const SizedBox(height: 6),
                      Text(
                          'Gentle repeating nudges. They work without a '
                          'connection.',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 22),
                    ],
                  );
                }
                if (_items.isEmpty) return _emptyState(p);
                final i = index - 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ReminderCard(
                    _items[i],
                    p,
                    onToggle: (v) => _toggle(_items[i], v),
                    onDelete: () => _delete(_items[i]),
                  ),
                );
              },
            ),
    );
  }

  Widget _permissionBanner(Palette p) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: p.tint(AppTheme.amber),
            borderRadius: BorderRadius.circular(AppTheme.radius)),
        child: Row(children: [
          const Icon(Icons.notifications_off_rounded, color: AppTheme.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Turn on notifications so reminders can reach you.',
                style: TextStyle(color: p.ink, fontSize: 13)),
          ),
          TextButton(
            onPressed: () async {
              _granted = await NotificationService.instance.requestPermission();
              if (mounted) setState(() {});
            },
            child: const Text('Enable'),
          ),
        ]),
      );

  Widget _emptyState(Palette p) => Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nothing scheduled yet', style: AppType.label.copyWith(color: p.subtle)),
            const SizedBox(height: 12),
            Text(
                'Reminders run on the phone itself, so they still fire with '
                'no signal. Add one to get started.',
                style: AppType.body.copyWith(color: p.subtle)),
          ],
        ),
      );
}

class _ReminderCard extends StatelessWidget {
  final Reminder r;
  final Palette p;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  const _ReminderCard(this.r, this.p,
      {required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = reminderColor(r.type);
    return SoftCard(
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
                color: color.withValues(alpha: p.isDark ? 0.28 : 0.14),
                borderRadius: BorderRadius.circular(AppTheme.radius)),
            child: Icon(reminderIcon(r.type), color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.title,
                    style:
                        TextStyle(fontWeight: FontWeight.w700, color: p.ink)),
                const SizedBox(height: 2),
                Text(r.everyLabel,
                    style: TextStyle(color: p.subtle, fontSize: 12.5)),
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value: r.enabled,
                activeThumbColor: AppTheme.green,
                onChanged: onToggle,
              ),
              InkWell(
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline_rounded,
                      size: 18, color: p.subtle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PresetPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final presets = [
      ...kReminderPresets,
      const ReminderPreset('custom', 'Custom reminder', '',
          Icons.edit_rounded, AppTheme.amber, 4),
    ];
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.72),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 8),
                child: Text('What should we remind you about?',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: p.ink, fontSize: 16)),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ...presets.map((preset) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: preset.color.withValues(alpha: 0.15),
                    child: Icon(preset.icon, color: preset.color),
                  ),
                  title: Text(preset.title,
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: p.ink)),
                  subtitle: preset.type == 'custom'
                      ? Text('Your own reminder',
                          style: TextStyle(color: p.subtle))
                      : Text(preset.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: p.subtle)),
                  onTap: () => Navigator.pop(context, preset),
                    )),
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

class _IntervalPicker extends StatefulWidget {
  final int defaultMinutes;
  const _IntervalPicker(this.defaultMinutes);
  @override
  State<_IntervalPicker> createState() => _IntervalPickerState();
}

class _IntervalPickerState extends State<_IntervalPicker> {
  final _custom = TextEditingController();

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  static const _normalOptions = [
    (30, '30 min'), (60, 'Every hour'), (120, 'Every 2 hours'),
    (180, 'Every 3 hours'), (240, 'Every 4 hours'), (360, 'Every 6 hours'),
    (480, 'Every 8 hours'), (720, 'Every 12 hours'), (1440, 'Every day'),
    (10080, 'Every week'),
  ];

  void _submitCustom() {
    final v = int.tryParse(_custom.text.trim());
    if (v == null || v < 1 || v > 43200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Enter a whole number of minutes between 1 and 43200.')));
      return;
    }
    Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final t = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppTheme.gutter, 0, AppTheme.gutter,
            16 + MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How often?', style: t.headlineSmall),
              const SizedBox(height: 16),
              Text('EVERYDAY', style: AppType.label.copyWith(color: p.subtle)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final (m, label) in _normalOptions)
                  _chip(label, m, p, AppTheme.green),
              ]),
              const SizedBox(height: 22),
              Text('OR SET YOUR OWN',
                  style: AppType.label.copyWith(color: p.subtle)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _custom,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        hintText: 'minutes, e.g. 3', isDense: true),
                    onSubmitted: (_) => _submitCustom(),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  style:
                      FilledButton.styleFrom(minimumSize: const Size(96, 48)),
                  onPressed: _submitCustom,
                  child: const Text('Set'),
                ),
              ]),
              const SizedBox(height: 14),
              Text(
                  'Android decides exactly when a repeating alarm fires, so a '
                  'short interval can drift by a minute or so.',
                  style: t.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, int minutes, Palette p, Color accent) {
    final selected = minutes == widget.defaultMinutes;
    return GestureDetector(
      onTap: () => Navigator.pop(context, minutes),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? accent : p.tint(accent),
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(
              color: selected ? accent : accent.withValues(alpha: 0.35),
              width: AppTheme.hair),
        ),
        child: Text(label,
            style: TextStyle(
                fontFamily: AppTheme.sans,
                color: selected ? Colors.white : p.ink,
                fontWeight: FontWeight.w600,
                fontSize: 13.5)),
      ),
    );
  }
}
