import 'package:json_annotation/json_annotation.dart';

import 'common.dart';

part 'stored_match.g.dart';

/// Ответ `GET /valorant/v1/stored-matches/{region}/{name}/{tag}`.
@JsonSerializable(checked: true, explicitToJson: true)
class StoredMatchesResponse {
  const StoredMatchesResponse({required this.status, required this.results, required this.data});

  factory StoredMatchesResponse.fromJson(Map<String, dynamic> json) =>
      _$StoredMatchesResponseFromJson(json);

  final int status;
  final PageInfo results;
  final List<StoredMatch> data;

  Map<String, dynamic> toJson() => _$StoredMatchesResponseToJson(this);
}

@JsonSerializable(checked: true)
class PageInfo {
  const PageInfo({required this.total, required this.returned, this.before = 0, this.after = 0});

  factory PageInfo.fromJson(Map<String, dynamic> json) => _$PageInfoFromJson(json);

  final int total;
  final int returned;
  @JsonKey(defaultValue: 0)
  final int before;
  @JsonKey(defaultValue: 0)
  final int after;

  Map<String, dynamic> toJson() => _$PageInfoToJson(this);
}

/// Элемент списка — один сыгранный матч (аналог «поста»).
@JsonSerializable(checked: true, explicitToJson: true)
class StoredMatch {
  const StoredMatch({required this.meta, required this.stats, required this.teams});

  factory StoredMatch.fromJson(Map<String, dynamic> json) => _$StoredMatchFromJson(json);

  final MatchMeta meta;
  final PlayerStats stats;
  final TeamScore teams;

  String get id => meta.id;

  /// Победил ли игрок: сравниваем счёт его команды с соперником.
  bool? get isWin {
    final team = stats.team.toLowerCase();
    if (teams.red == teams.blue) return null;
    if (team == 'red') return teams.red > teams.blue;
    if (team == 'blue') return teams.blue > teams.red;
    return null;
  }

  Map<String, dynamic> toJson() => _$StoredMatchToJson(this);
}

@JsonSerializable(checked: true, explicitToJson: true, fieldRename: FieldRename.snake)
class MatchMeta {
  const MatchMeta({
    required this.id,
    required this.map,
    required this.mode,
    required this.startedAt,
    this.version,
    this.season,
    this.region,
    this.cluster,
  });

  factory MatchMeta.fromJson(Map<String, dynamic> json) => _$MatchMetaFromJson(json);

  final String id;
  final IdName map;
  final String mode;
  final DateTime startedAt;
  final String? version;
  final Season? season;
  final String? region;
  final String? cluster;

  Map<String, dynamic> toJson() => _$MatchMetaToJson(this);
}

@JsonSerializable(checked: true)
class Season {
  const Season({required this.id, this.short});

  factory Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);

  final String id;
  final String? short;

  Map<String, dynamic> toJson() => _$SeasonToJson(this);
}

@JsonSerializable(checked: true, explicitToJson: true)
class PlayerStats {
  const PlayerStats({
    required this.puuid,
    required this.team,
    required this.character,
    required this.kills,
    required this.deaths,
    required this.assists,
    this.level = 0,
    this.tier = 0,
    this.score = 0,
    this.shots,
    this.damage,
    this.name,
    this.tag,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) => _$PlayerStatsFromJson(json);

  final String puuid;
  final String team;
  final IdName character;
  final int kills;
  final int deaths;
  final int assists;
  @JsonKey(defaultValue: 0)
  final int level;
  @JsonKey(defaultValue: 0)
  final int tier;
  @JsonKey(defaultValue: 0)
  final int score;
  final Shots? shots;
  final Damage? damage;
  final String? name;
  final String? tag;

  double get kda => (kills + assists) / (deaths == 0 ? 1 : deaths);

  /// Процент попаданий в голову, если есть данные по выстрелам.
  double? get headshotPercent {
    final s = shots;
    if (s == null) return null;
    final total = s.head + s.body + s.leg;
    return total == 0 ? null : s.head * 100 / total;
  }

  Map<String, dynamic> toJson() => _$PlayerStatsToJson(this);
}

@JsonSerializable(checked: true)
class Shots {
  const Shots({this.head = 0, this.body = 0, this.leg = 0});

  factory Shots.fromJson(Map<String, dynamic> json) => _$ShotsFromJson(json);

  @JsonKey(defaultValue: 0)
  final int head;
  @JsonKey(defaultValue: 0)
  final int body;
  @JsonKey(defaultValue: 0)
  final int leg;

  Map<String, dynamic> toJson() => _$ShotsToJson(this);
}

@JsonSerializable(checked: true)
class Damage {
  const Damage({this.made = 0, this.received = 0});

  factory Damage.fromJson(Map<String, dynamic> json) => _$DamageFromJson(json);

  @JsonKey(defaultValue: 0)
  final int made;
  @JsonKey(defaultValue: 0)
  final int received;

  Map<String, dynamic> toJson() => _$DamageToJson(this);
}

@JsonSerializable(checked: true)
class TeamScore {
  const TeamScore({required this.red, required this.blue});

  factory TeamScore.fromJson(Map<String, dynamic> json) => _$TeamScoreFromJson(json);

  final int red;
  final int blue;

  Map<String, dynamic> toJson() => _$TeamScoreToJson(this);
}
