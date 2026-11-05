import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_application_1/core/error/app_exception.dart';
import 'package:flutter_application_1/data/local/app_cache.dart';
import 'package:flutter_application_1/data/models/account.dart';
import 'package:flutter_application_1/data/models/match_details.dart';
import 'package:flutter_application_1/data/models/player_id.dart';
import 'package:flutter_application_1/data/models/stored_match.dart';
import 'package:flutter_application_1/data/repositories/match_repository.dart';
import 'package:flutter_application_1/presentation/state/matches_cubit.dart';
import 'package:flutter_application_1/presentation/state/matches_state.dart';
import 'package:flutter_application_1/presentation/state/resource.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fixtures.dart';

StoredMatch match(String id, {String map = 'Ascent', String agent = 'Jett', String startedAt = '2026-10-20T18:00:00.000Z'}) =>
    StoredMatch.fromJson(storedMatchJson(id: id, map: map, agent: agent, startedAt: startedAt));

/// Ручной фейк репозитория: каждый вызов fetchMatches ждёт, пока тест его завершит.
class FakeMatchRepository implements MatchRepository {
  final calls = <({MatchFilter filter, int page})>[];
  final pending = <Completer<MatchesPage>>[];
  CacheEntry<List<StoredMatch>>? cache;

  @override
  Future<MatchesPage> fetchMatches(PlayerId player, MatchFilter filter,
      {required int page, int size = 10, CancelToken? cancelToken}) {
    calls.add((filter: filter, page: page));
    final c = Completer<MatchesPage>();
    pending.add(c);
    return c.future;
  }

  void complete(int index, List<StoredMatch> items, {bool hasMore = true, int page = 1}) =>
      pending[index].complete(MatchesPage(items: items, page: page, hasMore: hasMore));

  @override
  CacheEntry<List<StoredMatch>>? cachedMatches(PlayerId player, MatchFilter filter) => cache;

  @override
  CacheEntry<Account>? cachedAccount(PlayerId player) => null;

  @override
  Future<Account> fetchAccount(PlayerId player) => Completer<Account>().future;

  @override
  PlayerId? savedPlayer() => null;

  @override
  Future<void> savePlayer(PlayerId player) async {}

  @override
  CacheEntry<List<String>>? cachedAgents() => null;

  @override
  Future<List<String>> fetchAgents() async => [];

  @override
  CacheEntry<MatchDetails>? cachedMatch(String matchId) => null;

  @override
  Future<MatchDetails> fetchMatch(String region, String matchId) => throw UnimplementedError();
}

Future<void> pump() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeMatchRepository repo;
  late MatchesCubit cubit;

  setUp(() {
    repo = FakeMatchRepository();
    cubit = MatchesCubit(repo, pageSize: 2);
  });

  tearDown(() => cubit.close());

  Future<void> loadFirstPage(List<StoredMatch> items, {bool hasMore = true}) async {
    final f = cubit.setPlayer(testPlayer);
    await pump();
    repo.complete(0, items, hasMore: hasMore);
    await f;
  }

  group('5. фильтрация и поиск', () {
    test('поиск по загруженным матчам: по карте и по агенту, без учёта регистра', () {
      final items = [match('1', map: 'Bind', agent: 'Sova'), match('2', map: 'Ascent', agent: 'Jett'), match('3', map: 'Haven', agent: 'Sova')];

      expect(MatchesState.applySearchAndSort(items, 'bind', SortOrder.newestFirst).map((m) => m.id), ['1']);
      expect(MatchesState.applySearchAndSort(items, 'SOVA', SortOrder.newestFirst).map((m) => m.id).toSet(), {'1', '3'});
      expect(MatchesState.applySearchAndSort(items, 'icebox', SortOrder.newestFirst), isEmpty);
    });

    test('сортировка по дате в обе стороны', () {
      final items = [
        match('old', startedAt: '2026-01-01T00:00:00Z'),
        match('new', startedAt: '2026-10-01T00:00:00Z'),
        match('mid', startedAt: '2026-05-01T00:00:00Z'),
      ];
      expect(MatchesState.applySearchAndSort(items, '', SortOrder.newestFirst).map((m) => m.id), ['new', 'mid', 'old']);
      expect(MatchesState.applySearchAndSort(items, '', SortOrder.oldestFirst).map((m) => m.id), ['old', 'mid', 'new']);
    });

    test('смена серверного фильтра сбрасывает страницы и не смешивает старые результаты с новыми', () async {
      await loadFirstPage([match('a'), match('b')]);
      expect(cubit.state.nextPage, 2);

      // Пользователь начал листать, а потом сменил фильтр.
      final next = cubit.loadNextPage();
      await pump();
      final filtered = cubit.setMap('Bind');
      await pump();
      expect(cubit.state.status, ViewStatus.loading);
      expect(cubit.state.items, isEmpty);

      // Ответ на устаревший запрос приходит позже — он должен быть проигнорирован.
      repo.complete(1, [match('stale')], page: 2);
      repo.complete(2, [match('bind-1', map: 'Bind')]);
      await Future.wait([next, filtered]);

      expect(repo.calls.last, (filter: const MatchFilter(map: 'Bind'), page: 1));
      expect(cubit.state.items.map((m) => m.id), ['bind-1']);
      expect(cubit.state.nextPage, 2);
    });

    test('сброс фильтров возвращает все матчи', () async {
      await loadFirstPage([match('a')]);
      final f = cubit.setMode('competitive');
      await pump();
      repo.complete(1, [match('c')]);
      await f;
      cubit.setQuery('asc');

      final reset = cubit.resetFilters();
      await pump();
      repo.complete(2, [match('a')]);
      await reset;

      expect(cubit.state.filter.isEmpty, isTrue);
      expect(cubit.state.query, '');
      expect(repo.calls.last.filter, const MatchFilter());
    });
  });

  group('6. пагинация', () {
    test('повторный вызов во время загрузки страницы не создаёт дублирующий запрос', () async {
      await loadFirstPage([match('a'), match('b')]);

      final first = cubit.loadNextPage();
      final second = cubit.loadNextPage();
      final third = cubit.loadNextPage();
      await pump();

      expect(repo.calls.where((c) => c.page == 2), hasLength(1));
      expect(cubit.state.pageStatus, PageStatus.loading);

      repo.complete(1, [match('b'), match('c')], page: 2); // 'b' пришёл повторно
      await Future.wait([first, second, third]);

      expect(cubit.state.items.map((m) => m.id), ['a', 'b', 'c']);
      expect(cubit.state.nextPage, 3);
    });

    test('ошибка следующей страницы не удаляет список, повтор загружает ту же страницу', () async {
      await loadFirstPage([match('a'), match('b')]);

      final f = cubit.loadNextPage();
      await pump();
      repo.pending[1].completeError(const NoConnectionException());
      await f;

      expect(cubit.state.pageStatus, PageStatus.error);
      expect(cubit.state.items, hasLength(2));

      final retry = cubit.loadNextPage();
      await pump();
      expect(repo.calls.last.page, 2);
      repo.complete(2, [match('c')], hasMore: false, page: 2);
      await retry;
      expect(cubit.state.hasMore, isFalse);
    });

    test('после последней страницы новые запросы не отправляются', () async {
      await loadFirstPage([match('a')], hasMore: false);
      await cubit.loadNextPage();
      expect(repo.calls, hasLength(1));
    });
  });

  group('кэш и офлайн', () {
    test('сначала показывается кэш, затем данные сервера', () async {
      repo.cache = CacheEntry([match('cached')], DateTime(2026, 10, 22));

      final f = cubit.setPlayer(testPlayer);
      await pump();
      expect(cubit.state.status, ViewStatus.cached);
      expect(cubit.state.isRefreshing, isTrue);
      expect(cubit.state.items.single.id, 'cached');

      repo.complete(0, [match('fresh')]);
      await f;
      expect(cubit.state.status, ViewStatus.success);
      expect(cubit.state.items.single.id, 'fresh');
    });

    test('без сети последний успешный результат остаётся на экране', () async {
      repo.cache = CacheEntry([match('cached')], DateTime(2026, 10, 22));

      final f = cubit.setPlayer(testPlayer);
      await pump();
      repo.pending[0].completeError(const NoConnectionException());
      await f;

      expect(cubit.state.status, ViewStatus.cached);
      expect(cubit.state.error, isA<NoConnectionException>());
      expect(cubit.state.items.single.id, 'cached');
    });

    test('без сети и без кэша — состояние Error, приложение не падает', () async {
      final f = cubit.setPlayer(testPlayer);
      await pump();
      repo.pending[0].completeError(const ServerException(500));
      await f;

      expect(cubit.state.status, ViewStatus.error);
      expect(cubit.state.error, isA<ServerException>());
    });

    test('пустой ответ сервера — состояние Empty', () async {
      await loadFirstPage([], hasMore: false);
      expect(cubit.state.status, ViewStatus.empty);
    });
  });
}
