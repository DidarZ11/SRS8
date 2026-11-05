import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/note.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/repositories/notes_repository.dart';
import '../state/create_note_cubit.dart';
import '../state/resource.dart';
import '../widgets/state_views.dart';


class CreateNoteScreen extends StatelessWidget {
  const CreateNoteScreen({super.key, this.matchId, this.defaultAgent});

  final String? matchId;
  final String? defaultAgent;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateNoteCubit(
        matches: context.read<MatchRepository>(),
        notes: context.read<NotesRepository>(),
        matchId: matchId,
      )..loadAgents(),
      child: _CreateNoteForm(defaultAgent: defaultAgent),
    );
  }
}

class _CreateNoteForm extends StatefulWidget {
  const _CreateNoteForm({this.defaultAgent});

  final String? defaultAgent;

  @override
  State<_CreateNoteForm> createState() => _CreateNoteFormState();
}

class _CreateNoteFormState extends State<_CreateNoteForm> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  String? _agent;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Проверка до отправки.
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await context.read<CreateNoteCubit>().submit(title: _title.text, body: _body.text, agent: _agent);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateNoteCubit, CreateNoteState>(
      listenWhen: (a, b) => a.submitStatus != b.submitStatus && b.submitStatus == SubmitStatus.failure,
      listener: (context, state) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось сохранить: ${state.error!.userMessage}')),
      ),
      builder: (context, state) {
        final created = state.created;
        return PopScope(
          canPop: !state.isSubmitting,
          onPopInvokedWithResult: (didPop, _) {},
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Новая заметка'),
              leading: created != null
                  ? IconButton(icon: const Icon(Icons.check), onPressed: () => Navigator.pop(context, created))
                  : null,
            ),
            body: created != null ? _result(context, created) : _form(context, state),
          ),
        );
      },
    );
  }

  Widget _form(BuildContext context, CreateNoteState state) {
    final agents = state.agents;
    final agentNames = agents.data ?? const <String>[];
    _agent ??= agentNames.contains(widget.defaultAgent) ? widget.defaultAgent : null;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        TextFormField(
          controller: _title,
          enabled: !state.isSubmitting,
          maxLength: NoteValidator.titleMax,
          decoration: const InputDecoration(labelText: 'Заголовок *', border: OutlineInputBorder()),
          validator: NoteValidator.title,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _body,
          enabled: !state.isSubmitting,
          maxLength: NoteValidator.bodyMax,
          minLines: 4,
          maxLines: 10,
          decoration: const InputDecoration(labelText: 'Текст *', border: OutlineInputBorder(), alignLabelWithHint: true),
          validator: NoteValidator.body,
        ),
        const SizedBox(height: 8),
        if (agents.status == ViewStatus.loading)
          const LinearProgressIndicator()
        else if (agents.status == ViewStatus.error)
          ErrorView(error: agents.error!, compact: true, onRetry: context.read<CreateNoteCubit>().loadAgents)
        else
          DropdownButtonFormField<String>(
            initialValue: _agent,
            decoration: InputDecoration(
              labelText: 'Агент *',
              border: const OutlineInputBorder(),
              helperText: agents.status == ViewStatus.cached ? 'Список агентов из кэша' : null,
            ),
            items: [for (final a in agentNames) DropdownMenuItem(value: a, child: Text(a))],
            onChanged: state.isSubmitting ? null : (v) => setState(() => _agent = v),
            validator: NoteValidator.agent,
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          // Блокировка повторного нажатия во время запроса.
          onPressed: state.isSubmitting ? null : _submit,
          icon: state.isSubmitting
              ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.send),
          label: Text(state.isSubmitting ? 'Отправляем…' : 'Сохранить'),
        ),
      ]),
    );
  }

  Widget _result(BuildContext context, Note note) {
    const encoder = JsonEncoder.withIndent('  ');
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Icon(Icons.check_circle, color: Colors.green, size: 48),
      const SizedBox(height: 8),
      Text('Сервер создал заметку #${note.id}', textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      const Text(
        'Она добавлена в список с пометкой «создано локально»: объект взят из ответа POST, '
        'а не из списка, который возвращает сервер. После обновления списка пометка исчезнет, '
        'если сервер вернёт эту заметку.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      Text('Ответ сервера:', style: Theme.of(context).textTheme.titleSmall),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SelectableText(
            encoder.convert(note.toJson()..remove('isLocal')),
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ),
      const SizedBox(height: 16),
      FilledButton(onPressed: () => Navigator.pop(context, note), child: const Text('К матчу')),
    ]);
  }
}
