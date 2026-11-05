import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../core/config/app_config.dart';
import '../../core/error/app_exception.dart';
import '../local/app_cache.dart';
import '../models/account.dart';
import '../models/match_details.dart';
import '../models/player_id.dart';
import '../models/stored_match.dart';
import '../remote/henrik_api.dart';

/// Серверный фильтр списка матчей. 
class MatchFilter extends Equatable {
  const MatchFilter({this.map, this.mode});

  static const maps = [
    'Abyss', 'Ascent', 'Bind', 'Breeze', 'Corrode', 'Fracture', 'Haven',
    'Icebox', 'Lotus', 'Pearl', 'Split', 'Sunset',
  ];
  static const modes = {
    'competitive': 'Рейтинг',
    'unrated': 'Без рейтинга',
    'swiftplay': 'Swiftplay',
    'deathmatch': 'Deathmatch',
    'teamdeathmatch': 'Team Deathmatch',
    'spikerush': 'Spike Rush',
  };

  final String? map;
  final String? mode;

  bool get isEmpty => map == null && mode == null;

  String get cacheKey => '${map ?? '*'}|${mode ?? '*'}';

  @override
  List<Object?> get props => [map, mode];
}

class MatchesPage {
  const MatchesPage({required this.items, required this.page, required this.hasMore});

  final List<StoredMatch> items;
  final int page;
  final bool hasMore;
}

/// Контракт репозитория — UI и state-слой не знают про Dio, Retrofit и Hive.
abstract interface class MatchRepository {
  CacheEntry<List<StoredMatch>>? cachedMatches(PlayerId player, MatchFilter filter);

  Future<MatchesPage> fetchMatches(
    PlayerId player,
    MatchFilter filter, {
    required int page,
    int size = AppConfig.pageSize,
    CancelToken? cancelToken,
  });

  CacheEntry<MatchDetails>? cachedMatch(String matchId);
  Future<MatchDetails> fetchMatch(String region, String matchId);

  CacheEntry<Account>? cachedAccount(PlayerId player);
  Future<Account> fetchAccount(PlayerId player);

  CacheEntry<List<String>>? cachedAgents();
  Future<List<String>> fetchAgents();

  PlayerId? savedPlayer();
  Future<void> savePlayer(PlayerId player);
}

class MatchRepositoryImpl implements MatchRepository {
  MatchRepositoryImpl({required this._api, required this._cache});

  final HenrikApi _api;
  final AppCache _cache;

  static String _matchesKey(PlayerId p, MatchFilter f) => 'matches:${p.key}:${f.cacheKey}';

  @override
  CacheEntry<List<StoredMatch>>? cachedMatches(PlayerId player, MatchFilter filter) =>
      _cache.read(_matchesKey(player, filter), (json) => [
            for (final m in json as List) StoredMatch.fromJson(m as Map<String, dynamic>),
          ]);

  @override
  Future<MatchesPage> fetchMatches(
    PlayerId player,
    MatchFilter filter, {
    required int page,
    int size = AppConfig.pageSize,
    CancelToken? cancelToken,
  }) =>
      _guard(() async {
        final response = await _api.getStoredMatches(
          player.region,
          Uri.encodeComponent(player.name),
          Uri.encodeComponent(player.tag),
          page: page,
          size: size,
          map: filter.map,
          mode: filter.mode,
          cancelToken: cancelToken,
        );
        final items = response.data;
        final total = response.results.total;
        final hasMore = items.length >= size && (total == 0 || page * size < total);

        // Обновляем кэш только после успешного ответа.
        // Первая страница заменяет кэш, следующие — дописываются без дубликатов.
        final key = _matchesKey(player, filter);
        final List<StoredMatch> toCache;
        if (page == 1) {
          toCache = items;
        } else {
          final existing = cachedMatches(player, filter)?.data ?? const <StoredMatch>[];
          final ids = existing.map((m) => m.id).toSet();
          toCache = [...existing, ...items.where((m) => ids.add(m.id))];
        }
        await _cache.write(key, [for (final m in toCache) m.toJson()]);

        return MatchesPage(items: items, page: page, hasMore: hasMore);
      });

  @override
  CacheEntry<MatchDetails>? cachedMatch(String matchId) =>
      _cache.read('match:$matchId', (json) => MatchDetails.fromJson(json as Map<String, dynamic>));

  @override
  Future<MatchDetails> fetchMatch(String region, String matchId) => _guard(() async {
        final response = await _api.getMatch(region, matchId);
        await _cache.write('match:$matchId', response.data.toJson());
        return response.data;
      });

  @override
  CacheEntry<Account>? cachedAccount(PlayerId player) =>
      _cache.read('account:${player.key}', (json) => Account.fromJson(json as Map<String, dynamic>));

  @override
  Future<Account> fetchAccount(PlayerId player) => _guard(() async {
        final response = await _api.getAccount(
          Uri.encodeComponent(player.name),
          Uri.encodeComponent(player.tag),
        );
        await _cache.write('account:${player.key}', response.data.toJson());
        return response.data;
      });

  @override
  CacheEntry<List<String>>? cachedAgents() =>
      _cache.read('agents', (json) => [for (final a in json as List) a as String]);

  @override
  Future<List<String>> fetchAgents() => _guard(() async {
        final response = await _api.getContent();
        final agents = response.data.agentNames;
        await _cache.write('agents', agents);
        return agents;
      });

  @override
  PlayerId? savedPlayer() =>
      _cache.read('settings:player', (json) => PlayerId.fromJson(json as Map<String, dynamic>))?.data;

  @override
  Future<void> savePlayer(PlayerId player) => _cache.write('settings:player', player.toJson());
}

/// Любая ошибка сети/парсинга превращается в [AppException].
Future<T> _guard<T>(Future<T> Function() body) async {
  try {
    return await body();
  } catch (e, st) {
    throw ErrorMapper.map(e, st);
  }
}
