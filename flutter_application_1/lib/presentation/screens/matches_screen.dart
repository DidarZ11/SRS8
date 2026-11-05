import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/account.dart';
import '../../data/models/stored_match.dart';
import '../../data/repositories/match_repository.dart';
import '../state/matches_cubit.dart';
import '../state/matches_state.dart';
import '../state/resource.dart';
import '../widgets/match_tile.dart';
import '../widgets/player_dialog.dart';
import '../widgets/state_views.dart';
import 'match_details_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final _scroll = ScrollController();
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    // За 300 px до конца списка просим следующую страницу; повторы отсекает Cubit.
    if (_scroll.position.extentAfter < 300) context.read<MatchesCubit>().loadNextPage();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _changePlayer() async {
    final cubit = context.read<MatchesCubit>();
    final player = await showPlayerDialog(context, initial: cubit.state.player);
    if (player != null) {
      _search.clear();
      await cubit.setPlayer(player);
    }
  }

  void _openMatch(StoredMatch match) {
    final player = context.read<MatchesCubit>().state.player!;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => MatchDetailsScreen(match: match, region: player.region, puuid: match.stats.puuid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MatchesCubit, MatchesState>(
      listenWhen: (a, b) => b.error != null && a.error != b.error && b.items.isNotEmpty,
      listener: (context, state) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Не удалось обновить: ${state.error!.userMessage}'))),
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state.player?.riotId ?? 'Valorant Explorer'),
            actions: [
              IconButton(
                tooltip: 'Сменить игрока',
                icon: const Icon(Icons.person_search),
                onPressed: _changePlayer,
              ),
            ],
          ),
          body: state.player == null ? _noPlayer() : _body(context, state),
        );
      },
    );
  }

  Widget _noPlayer() => EmptyView(
        icon: Icons.sports_esports_outlined,
        message: 'Укажите Riot ID, чтобы посмотреть историю матчей.',
        action: FilledButton(onPressed: _changePlayer, child: const Text('Выбрать игрока')),
      );

  Widget _body(BuildContext context, MatchesState state) {
    final cubit = context.read<MatchesCubit>();
    return Column(children: [
      _AccountHeader(account: state.account),
      _FilterBar(state: state, search: _search),
      if (state.status == ViewStatus.cached)
        CachedBanner(cachedAt: state.cachedAt, refreshing: state.isRefreshing, error: state.error),
      Expanded(
        child: RefreshIndicator(
          onRefresh: cubit.refresh,
          child: _list(context, state),
        ),
      ),
    ]);
  }

  Widget _list(BuildContext context, MatchesState state) {
    final cubit = context.read<MatchesCubit>();

    // Для Loading/Error/Empty тоже нужен скроллируемый виджет — иначе не работает pull-to-refresh.
    Widget scrollable(Widget child) => LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(height: c.maxHeight, child: child),
          ),
        );

    switch (state.status) {
      case ViewStatus.loading:
        return scrollable(const LoadingView(message: 'Загружаем матчи…'));
      case ViewStatus.error:
        return scrollable(ErrorView(error: state.error!, onRetry: cubit.load));
      case ViewStatus.empty:
        return scrollable(EmptyView(
          message: state.filter.isEmpty ? 'Матчей пока нет.' : 'Нет матчей с выбранными фильтрами.',
          action: state.filter.isEmpty
              ? null
              : TextButton(onPressed: cubit.resetFilters, child: const Text('Сбросить фильтры')),
        ));
      case ViewStatus.success:
      case ViewStatus.cached:
        break;
    }

    final items = state.visibleItems;
    if (items.isEmpty && state.isSearching) {
      return scrollable(EmptyView(
        icon: Icons.search_off,
        message: 'Среди ${state.items.length} загруженных матчей ничего не найдено по «${state.query}».',
      ));
    }

    return ListView.builder(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: items.length + 1,
      itemBuilder: (context, i) {
        if (i < items.length) return MatchTile(match: items[i], onTap: () => _openMatch(items[i]));
        return _Footer(state: state, onRetry: cubit.loadNextPage);
      },
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state, required this.onRetry});

  final MatchesState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isSearching) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Поиск идёт только по загруженным матчам. Очистите поиск, чтобы загрузить ещё.',
            textAlign: TextAlign.center),
      );
    }
    return switch (state.pageStatus) {
      PageStatus.loading => const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      PageStatus.error => ErrorView(error: state.pageError!, onRetry: onRetry, compact: true),
      PageStatus.idle => Padding(
          padding: const EdgeInsets.all(16),
          child: state.hasMore
              ? Center(child: TextButton(onPressed: onRetry, child: const Text('Загрузить ещё')))
              : Text('Больше матчей нет · всего ${state.items.length}', textAlign: TextAlign.center),
        ),
    };
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.account});

  final Resource<Account> account;

  @override
  Widget build(BuildContext context) {
    final a = account.data;
    if (a == null) {
      return account.status == ViewStatus.loading
          ? const LinearProgressIndicator(minHeight: 2)
          : const SizedBox.shrink();
    }
    return ListTile(
      leading: a.cardImageUrl == null
          ? const CircleAvatar(child: Icon(Icons.person))
          : CircleAvatar(
              backgroundImage: NetworkImage(a.cardImageUrl!),
              onBackgroundImageError: (_, _) {},
            ),
      title: Text(a.name + (a.tag.isEmpty ? '' : '#${a.tag}')),
      subtitle: Text('Уровень ${a.accountLevel} · регион ${a.region.toUpperCase()}'
          '${account.status == ViewStatus.cached ? ' · из кэша' : ''}'),
      dense: true,
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.state, required this.search});

  final MatchesState state;
  final TextEditingController search;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MatchesCubit>();
    final hasAnyFilter = !state.filter.isEmpty || state.isSearching || state.sort != SortOrder.newestFirst;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(
          controller: search,
          onChanged: cubit.setQuery,
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: const Icon(Icons.search),
            hintText: 'Карта, агент или режим',
            helperText: 'Поиск среди загруженных матчей (${state.items.length}), не по всей истории',
            border: const OutlineInputBorder(),
            suffixIcon: state.isSearching
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      search.clear();
                      cubit.setQuery('');
                    },
                  )
                : null,
          ),
        ),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _Dropdown(
              label: 'Карта',
              value: state.filter.map,
              options: {for (final m in MatchFilter.maps) m: m},
              onChanged: cubit.setMap,
            ),
            const SizedBox(width: 8),
            _Dropdown(
              label: 'Режим',
              value: state.filter.mode,
              options: MatchFilter.modes,
              onChanged: cubit.setMode,
            ),
            const SizedBox(width: 8),
            ActionChip(
              avatar: Icon(state.sort == SortOrder.newestFirst ? Icons.arrow_downward : Icons.arrow_upward, size: 18),
              label: Text(state.sort == SortOrder.newestFirst ? 'Сначала новые' : 'Сначала старые'),
              onPressed: cubit.toggleSort,
            ),
            const SizedBox(width: 8),
            if (hasAnyFilter)
              ActionChip(
                avatar: const Icon(Icons.filter_alt_off, size: 18),
                label: const Text('Сбросить'),
                onPressed: () {
                  search.clear();
                  cubit.resetFilters();
                },
              ),
          ]),
        ),
      ]),
    );
  }
}

/// Выпадающий фильтр: «Все» ↔ конкретное значение (серверная фильтрация).
class _Dropdown extends StatelessWidget {
  const _Dropdown({required this.label, required this.value, required this.options, required this.onChanged});

  final String label;
  final String? value;
  final Map<String, String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      selected: value != null,
      label: Text(value == null ? '$label: все' : '$label: ${options[value] ?? value}'),
      onPressed: () async {
        final picked = await showModalBottomSheet<String>(
          context: context,
          builder: (context) => SafeArea(
            child: ListView(shrinkWrap: true, children: [
              ListTile(title: Text('$label: все'), onTap: () => Navigator.pop(context, '')),
              for (final e in options.entries)
                ListTile(
                  title: Text(e.value),
                  trailing: e.key == value ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.pop(context, e.key),
                ),
            ]),
          ),
        );
        if (picked != null) onChanged(picked.isEmpty ? null : picked);
      },
    );
  }
}
