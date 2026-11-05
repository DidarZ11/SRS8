import 'package:equatable/equatable.dart';

import '../../core/error/app_exception.dart';
import '../../data/models/account.dart';
import '../../data/models/player_id.dart';
import '../../data/models/stored_match.dart';
import '../../data/repositories/match_repository.dart';
import 'resource.dart';

enum PageStatus { idle, loading, error }

enum SortOrder { newestFirst, oldestFirst }

class MatchesState extends Equatable {
  const MatchesState({
    this.player,
    this.status = ViewStatus.loading,
    this.items = const [],
    this.filter = const MatchFilter(),
    this.query = '',
    this.sort = SortOrder.newestFirst,
    this.nextPage = 1,
    this.hasMore = true,
    this.pageStatus = PageStatus.idle,
    this.isRefreshing = false,
    this.error,
    this.pageError,
    this.cachedAt,
    this.account = const Resource.loading(),
  });

  /// null — игрок ещё не указан, нужно открыть настройки.
  final PlayerId? player;

  final ViewStatus status;
  final List<StoredMatch> items;
  final MatchFilter filter;

  /// Локальный поиск по загруженным матчам (карта / агент).
  final String query;
  final SortOrder sort;

  final int nextPage;
  final bool hasMore;
  final PageStatus pageStatus;

  /// Идёт запрос первой страницы, а на экране уже есть данные (кэш или pull-to-refresh).
  final bool isRefreshing;

  /// Ошибка загрузки списка (при status == cached — сервер недоступен).
  final AppException? error;

  /// Ошибка подгрузки следующей страницы.
  final AppException? pageError;

  final DateTime? cachedAt;

  final Resource<Account> account;

  bool get isSearching => query.trim().isNotEmpty;

  /// То, что видит пользователь: поиск и сортировка по загруженным данным.
  List<StoredMatch> get visibleItems => applySearchAndSort(items, query, sort);

  static List<StoredMatch> applySearchAndSort(List<StoredMatch> items, String query, SortOrder sort) {
    final q = query.trim().toLowerCase();
    final result = q.isEmpty
        ? [...items]
        : items
            .where((m) =>
                m.meta.map.name.toLowerCase().contains(q) ||
                m.stats.character.name.toLowerCase().contains(q) ||
                m.meta.mode.toLowerCase().contains(q))
            .toList();
    result.sort((a, b) => sort == SortOrder.newestFirst
        ? b.meta.startedAt.compareTo(a.meta.startedAt)
        : a.meta.startedAt.compareTo(b.meta.startedAt));
    return result;
  }

  MatchesState copyWith({
    PlayerId? player,
    ViewStatus? status,
    List<StoredMatch>? items,
    MatchFilter? filter,
    String? query,
    SortOrder? sort,
    int? nextPage,
    bool? hasMore,
    PageStatus? pageStatus,
    bool? isRefreshing,
    AppException? Function()? error,
    AppException? Function()? pageError,
    DateTime? Function()? cachedAt,
    Resource<Account>? account,
  }) {
    return MatchesState(
      player: player ?? this.player,
      status: status ?? this.status,
      items: items ?? this.items,
      filter: filter ?? this.filter,
      query: query ?? this.query,
      sort: sort ?? this.sort,
      nextPage: nextPage ?? this.nextPage,
      hasMore: hasMore ?? this.hasMore,
      pageStatus: pageStatus ?? this.pageStatus,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error != null ? error() : this.error,
      pageError: pageError != null ? pageError() : this.pageError,
      cachedAt: cachedAt != null ? cachedAt() : this.cachedAt,
      account: account ?? this.account,
    );
  }

  @override
  List<Object?> get props => [
        player, status, items, filter, query, sort, nextPage, hasMore,
        pageStatus, isRefreshing, error, pageError, cachedAt, account,
      ];
}
