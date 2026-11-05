import 'package:flutter/material.dart';

import '../../data/models/player_id.dart';

/// Диалог выбора игрока (Riot ID + регион).
Future<PlayerId?> showPlayerDialog(BuildContext context, {PlayerId? initial}) {
  return showDialog<PlayerId>(context: context, builder: (_) => _PlayerDialog(initial: initial));
}

class _PlayerDialog extends StatefulWidget {
  const _PlayerDialog({this.initial});

  final PlayerId? initial;

  @override
  State<_PlayerDialog> createState() => _PlayerDialogState();
}

class _PlayerDialogState extends State<_PlayerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _tag = TextEditingController(text: widget.initial?.tag);
  late String _region = widget.initial?.region ?? 'eu';

  @override
  void dispose() {
    _name.dispose();
    _tag.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      PlayerId(region: _region, name: _name.text.trim(), tag: _tag.text.trim().replaceAll('#', '')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Игрок'),
      content: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Riot ID (имя)'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите имя' : null,
          ),
          TextFormField(
            controller: _tag,
            decoration: const InputDecoration(labelText: 'Тег', prefixText: '#'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите тег' : null,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _region,
            decoration: const InputDecoration(labelText: 'Регион'),
            items: [
              for (final r in PlayerId.regions) DropdownMenuItem(value: r, child: Text(r.toUpperCase())),
            ],
            onChanged: (v) => setState(() => _region = v ?? 'eu'),
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        FilledButton(onPressed: _submit, child: const Text('Показать матчи')),
      ],
    );
  }
}
