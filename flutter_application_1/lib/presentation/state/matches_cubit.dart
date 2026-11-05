import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/config/app_config.dart';
import '../../core/error/app_exception.dart';
import '../../data/models/player_id.dart';
import '../../data/repositories/match_repository.dart';
import 'matches_state.dart';
import 'resource.dart';

class MatchesCubit extends Cubit<MatchesState> {
  MatchesCubit(this._repository, {this.pageSize = AppConfig.pageSize}) : super(const MatchesState());

  final MatchRepository _repository;
  final int pageSize;

  /// Номер «поколения» списка. Меняется при смене игрока/фильтра,
  /// чтобы ответы устаревших запросов не смешивались с новыми результатами.
  int _generation = 0;
  CancelToken? _cancelToken;

  /// Запуск: игрок из настроек → из env.json → экран настроек.
  Future<void> start() async {
    final player = _repository.savedPlayer() ??
        (AppConfig.defaultName.isNotEmpty && AppConfig.defaultTag.isNotEmpty
            ? const PlayerId(
                region: AppConfig.defaultRegion,
                name: AppConfig.defaultName,
                tag: AppConfig.defaultTag,
              )
            : null);
    if (player == null) {
      emit(state.copyWith(status: ViewStatus.empty));
      return;
    }
    await setPlayer(player, persist: false);
  }

  Future<void> setPlayer(PlayerId player, {bool persist = true}) async {
    if (persist) await _repository.savePlayer(player);
    emit(MatchesState(player: player, sort: state.sort));
    _loadAccount(player);
    await load();
  }

  /// Первая страница: сначала кэш, затем сервер.
  Future<void> load() async {
    final player = state.player;
    if (player == null) return;

    final generation = ++_generation;
    _cancelToken?.cancel('filter changed');
    final cancelToken = _cancelToken = CancelToken();

    final cached = _repository.cachedMatches(player, state.filter);
    if (cached != null) {
      emit(state.copyWith(
        status: ViewStatus.cached,
        items: cached.data,
        cachedAt: () => cached.savedAt,
        nextPage: (cached.data.length / pageSize).ceil() + 1,
        hasMore: cached.data.length >= pageSize,
        isRefreshing: true,
        pageStatus: PageStatus.idle,
        error: () => null,
        pageError: () => null,
      ));
    } else {
      emit(state.copyWith(
        status: ViewStatus.loading,
        items: const [],
        cachedAt: () => null,
        nextPage: 1,
        hasMore: true,
        isRefreshing: false,
        pageStatus: PageStatus.idle,
        error: () => null,
        pageError: () => null,
      ));
    }
    await _fetchFirstPage(generation, cancelToken);
  }

  /// Pull-to-refresh: список остаётся на экране, пока идёт запрос.
  Future<void> refresh() async {
    if (state.player == null) return;
    if (state.items.isEmpty) return load();
    final generation = ++_generation;
    _cancelToken?.cancel('refresh');
    final cancelToken = _cancelToken = CancelToken();
    emit(state.copyWith(isRefreshing: true, pageStatus: PageStatus.idle, pageError: () => null));
    await _fetchFirstPage(generation, cancelToken);
  }

  Future<void> _fetchFirstPage(int generation, CancelToken cancelToken) async {
    try {
      final page = await _repository.fetchMatches(
        state.player!,
        state.filter,
        page: 1,
        size: pageSize,
        cancelToken: cancelToken,
      );
      if (generation != _generation) return;
      emit(state.copyWith(
        status: page.items.isEmpty ? ViewStatus.empty : ViewStatus.success,
        items: page.items,
        nextPage: 2,
        hasMore: page.hasMore,
        isRefreshing: false,
        error: () => null,
        cachedAt: () => null,
      ));
    } on AppException catch (e) {
      if (generation != _generation || e is CancelledException) return;
      // Последний успешный результат не удаляем — просто помечаем, что он из кэша.
      if (state.items.isNotEmpty) {
        emit(state.copyWith(
          status: ViewStatus.cached,
          isRefreshing: false,
          error: () => e,
          cachedAt: () => state.cachedAt ?? DateTime.now(),
        ));
      } else {
        emit(state.copyWith(status: ViewStatus.error, isRefreshing: false, error: () => e));
      }
    }
  }

  /// Подгрузка следующей страницы с защитой от повторного вызова.
  Future<void> loadNextPage() async {
    final s = state;
    if (s.player == null ||
        s.pageStatus == PageStatus.loading ||
        !s.hasMore ||
        s.isRefreshing ||
        s.status == ViewStatus.loading ||
        s.status == ViewStatus.error ||
        s.isSearching) {
      return;
    }
    final generation = _generation;
    final page = s.nextPage;
    // emit синхронный: второй вызов увидит PageStatus.loading и выйдет.
    emit(s.copyWith(pageStatus: PageStatus.loading, pageError: () => null));
    try {
      final result = await _repository.fetchMatches(
        s.player!,
        s.filter,
        page: page,
        size: pageSize,
        cancelToken: _cancelToken,
      );
      if (generation != _generation) return;
      final ids = state.items.map((m) => m.id).toSet();
      final fresh = result.items.where((m) => ids.add(m.id)).toList();
      emit(state.copyWith(
        items: [...state.items, ...fresh],
        nextPage: page + 1,
        hasMore: result.hasMore,
        pageStatus: PageStatus.idle,
      ));
    } on AppException catch (e) {
      if (generation != _generation || e is CancelledException) return;
      emit(state.copyWith(pageStatus: PageStatus.error, pageError: () => e));
    }
  }

  // ---- Фильтры: серверные сбрасывают страницы, поиск и сортировка — локальные.

  Future<void> setMap(String? map) => _applyFilter(MatchFilter(map: map, mode: state.filter.mode));

  Future<void> setMode(String? mode) => _applyFilter(MatchFilter(map: state.filter.map, mode: mode));

  Future<void> _applyFilter(MatchFilter filter) async {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter));
    await load();
  }

  void setQuery(String query) => emit(state.copyWith(query: query));

  void toggleSort() => emit(state.copyWith(
        sort: state.sort == SortOrder.newestFirst ? SortOrder.oldestFirst : SortOrder.newestFirst,
      ));

  Future<void> resetFilters() async {
    final serverFilterChanged = !state.filter.isEmpty;
    emit(state.copyWith(filter: const MatchFilter(), query: '', sort: SortOrder.newestFirst));
    if (serverFilterChanged) await load();
  }

  Future<void> _loadAccount(PlayerId player) async {
    final cached = _repository.cachedAccount(player);
    emit(state.copyWith(
      account: cached != null ? Resource.cached(cached.data, cached.savedAt, refreshing: true) : const Resource.loading(),
    ));
    try {
      final account = await _repository.fetchAccount(player);
      if (state.player == player) emit(state.copyWith(account: Resource.success(account)));
    } on AppException catch (e) {
      if (state.player != player) return;
      emit(state.copyWith(
        account: cached != null ? Resource.cached(cached.data, cached.savedAt, error: e) : Resource.error(e),
      ));
    }
  }

  @override
  Future<void> close() {
    _cancelToken?.cancel('closed');
    return super.close();
  }
}
