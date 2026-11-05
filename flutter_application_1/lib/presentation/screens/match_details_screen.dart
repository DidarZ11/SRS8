import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/match_details.dart';
import '../../data/models/note.dart';
import '../../data/models/stored_match.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/repositories/notes_repository.dart';
import '../state/match_details_cubit.dart';
import '../state/resource.dart';
import '../widgets/state_views.dart';
import 'create_note_screen.dart';

class MatchDetailsScreen extends StatelessWidget {
  const MatchDetailsScreen({super.key, required this.match, required this.region, required this.puuid});

  final StoredMatch match;
  final String region;

  /// puuid игрока, чью историю смотрим — выделяем его в таблице.
  final String puuid;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MatchDetailsCubit(
        matches: context.read<MatchRepository>(),
        notes: context.read<NotesRepository>(),
        region: region,
        matchId: match.id,
      )..load(),
      child: _DetailsView(match: match, puuid: puuid),
    );
  }
}

class _DetailsView extends StatelessWidget {
  const _DetailsView({required this.match, required this.puuid});

  final StoredMatch match;
  final String puuid;

  Future<void> _createNote(BuildContext context) async {
    final cubit = context.read<MatchDetailsCubit>();
    final created = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => CreateNoteScreen(matchId: match.id, defaultAgent: match.stats.character.name)),
    );
    if (created != null) cubit.addLocalNote(created);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MatchDetailsCubit>();
    return Scaffold(
      appBar: AppBar(title: Text('${match.meta.map.name} · ${match.meta.mode}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNote(context),
        icon: const Icon(Icons.note_add),
        label: const Text('Заметка'),
      ),
      body: BlocBuilder<MatchDetailsCubit, MatchDetailsState>(
        builder: (context, state) => RefreshIndicator(
          onRefresh: cubit.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              _section(context, 'Матч'),
              ..._details(context, state.details),
              _section(context, 'Мои заметки к матчу'),
              ..._notes(context, state.notes),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      );

  List<Widget> _details(BuildContext context, Resource<MatchDetails> r) {
    final cubit = context.read<MatchDetailsCubit>();
    final d = r.data;
    return [
      if (r.status == ViewStatus.cached) CachedBanner(cachedAt: r.cachedAt, refreshing: r.refreshing, error: r.error),
      if (r.status == ViewStatus.loading) const SizedBox(height: 160, child: LoadingView()),
      if (r.status == ViewStatus.error) ErrorView(error: r.error!, onRetry: cubit.loadDetails),
      if (d != null) ...[
        _summary(context, d),
        for (final team in _teams(d)) ..._teamTable(context, d, team),
      ],
    ];
  }

  List<String> _teams(MatchDetails d) {
    final ids = d.players.map((p) => p.teamId).toSet().toList()..sort();
    return ids;
  }

  Widget _summary(BuildContext context, MatchDetails d) {
    final m = d.metadata;
    final minutes = m.gameLengthInMs == null ? null : (m.gameLengthInMs! / 60000).round();
    final score = d.teams.map((t) => '${t.teamId}: ${t.rounds?.won ?? '-'}').join('  ·  ');
    return ListTile(
      leading: const Icon(Icons.map_outlined),
      title: Text('${m.map.name} — ${m.queue.name ?? m.queue.id}'),
      subtitle: Text([
        formatDateTime(m.startedAt),
        if (minutes != null) '$minutes мин',
        if (score.isNotEmpty) score,
      ].join('\n')),
      isThreeLine: true,
    );
  }

  List<Widget> _teamTable(BuildContext context, MatchDetails d, String teamId) {
    final team = d.teams.where((t) => t.teamId == teamId).firstOrNull;
    final players = d.players.where((p) => p.teamId == teamId).toList()
      ..sort((a, b) => b.stats.score.compareTo(a.stats.score));
    final scheme = Theme.of(context).colorScheme;
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Text(
          'Команда $teamId${team == null ? '' : team.won ? ' — победа' : ' — поражение'}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: team?.won == true ? Colors.green.shade600 : scheme.error,
              ),
        ),
      ),
      for (final p in players)
        ListTile(
          dense: true,
          selected: p.puuid == puuid,
          leading: CircleAvatar(child: Text(p.agent.name.isEmpty ? '?' : p.agent.name[0])),
          title: Text('${p.name}#${p.tag}', overflow: TextOverflow.ellipsis),
          subtitle: Text('${p.agent.name}${p.tier == null ? '' : ' · ${p.tier!.name}'}'),
          trailing: Text('${p.stats.kills}/${p.stats.deaths}/${p.stats.assists}\nACS-score ${p.stats.score}',
              textAlign: TextAlign.end),
        ),
    ];
  }

  List<Widget> _notes(BuildContext context, Resource<List<Note>> r) {
    final cubit = context.read<MatchDetailsCubit>();
    return [
      if (r.status == ViewStatus.cached) CachedBanner(cachedAt: r.cachedAt, refreshing: r.refreshing, error: r.error),
      if (r.status == ViewStatus.loading) const SizedBox(height: 80, child: LoadingView()),
      if (r.status == ViewStatus.error) ErrorView(error: r.error!, onRetry: cubit.loadNotes, compact: true),
      if (r.status == ViewStatus.empty)
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Заметок пока нет. Нажмите «Заметка», чтобы добавить.'),
        ),
      for (final n in r.data ?? const <Note>[]) _NoteCard(note: n),
    ];
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(note.title, style: Theme.of(context).textTheme.titleMedium)),
            if (note.isLocal)
              const Chip(
                label: Text('создано локально'),
                avatar: Icon(Icons.phone_android, size: 16),
                visualDensity: VisualDensity.compact,
              ),
          ]),
          const SizedBox(height: 4),
          Text(note.body),
          const SizedBox(height: 4),
          Text(
            '${note.agent} · #${note.id}${note.createdAt == null ? '' : ' · ${formatDateTime(note.createdAt!)}'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ]),
      ),
    );
  }
}
