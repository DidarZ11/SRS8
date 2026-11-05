// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stored_match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoredMatchesResponse _$StoredMatchesResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('StoredMatchesResponse', json, ($checkedConvert) {
  final val = StoredMatchesResponse(
    status: $checkedConvert('status', (v) => (v as num).toInt()),
    results: $checkedConvert(
      'results',
      (v) => PageInfo.fromJson(v as Map<String, dynamic>),
    ),
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => StoredMatch.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$StoredMatchesResponseToJson(
  StoredMatchesResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'results': instance.results.toJson(),
  'data': instance.data.map((e) => e.toJson()).toList(),
};

PageInfo _$PageInfoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PageInfo', json, ($checkedConvert) {
      final val = PageInfo(
        total: $checkedConvert('total', (v) => (v as num).toInt()),
        returned: $checkedConvert('returned', (v) => (v as num).toInt()),
        before: $checkedConvert('before', (v) => (v as num?)?.toInt() ?? 0),
        after: $checkedConvert('after', (v) => (v as num?)?.toInt() ?? 0),
      );
      return val;
    });

Map<String, dynamic> _$PageInfoToJson(PageInfo instance) => <String, dynamic>{
  'total': instance.total,
  'returned': instance.returned,
  'before': instance.before,
  'after': instance.after,
};

StoredMatch _$StoredMatchFromJson(Map<String, dynamic> json) =>
    $checkedCreate('StoredMatch', json, ($checkedConvert) {
      final val = StoredMatch(
        meta: $checkedConvert(
          'meta',
          (v) => MatchMeta.fromJson(v as Map<String, dynamic>),
        ),
        stats: $checkedConvert(
          'stats',
          (v) => PlayerStats.fromJson(v as Map<String, dynamic>),
        ),
        teams: $checkedConvert(
          'teams',
          (v) => TeamScore.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$StoredMatchToJson(StoredMatch instance) =>
    <String, dynamic>{
      'meta': instance.meta.toJson(),
      'stats': instance.stats.toJson(),
      'teams': instance.teams.toJson(),
    };

MatchMeta _$MatchMetaFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MatchMeta', json, ($checkedConvert) {
      final val = MatchMeta(
        id: $checkedConvert('id', (v) => v as String),
        map: $checkedConvert(
          'map',
          (v) => IdName.fromJson(v as Map<String, dynamic>),
        ),
        mode: $checkedConvert('mode', (v) => v as String),
        startedAt: $checkedConvert(
          'started_at',
          (v) => DateTime.parse(v as String),
        ),
        version: $checkedConvert('version', (v) => v as String?),
        season: $checkedConvert(
          'season',
          (v) => v == null ? null : Season.fromJson(v as Map<String, dynamic>),
        ),
        region: $checkedConvert('region', (v) => v as String?),
        cluster: $checkedConvert('cluster', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'startedAt': 'started_at'});

Map<String, dynamic> _$MatchMetaToJson(MatchMeta instance) => <String, dynamic>{
  'id': instance.id,
  'map': instance.map.toJson(),
  'mode': instance.mode,
  'started_at': instance.startedAt.toIso8601String(),
  'version': instance.version,
  'season': instance.season?.toJson(),
  'region': instance.region,
  'cluster': instance.cluster,
};

Season _$SeasonFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Season', json, ($checkedConvert) {
      final val = Season(
        id: $checkedConvert('id', (v) => v as String),
        short: $checkedConvert('short', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$SeasonToJson(Season instance) => <String, dynamic>{
  'id': instance.id,
  'short': instance.short,
};

PlayerStats _$PlayerStatsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PlayerStats', json, ($checkedConvert) {
      final val = PlayerStats(
        puuid: $checkedConvert('puuid', (v) => v as String),
        team: $checkedConvert('team', (v) => v as String),
        character: $checkedConvert(
          'character',
          (v) => IdName.fromJson(v as Map<String, dynamic>),
        ),
        kills: $checkedConvert('kills', (v) => (v as num).toInt()),
        deaths: $checkedConvert('deaths', (v) => (v as num).toInt()),
        assists: $checkedConvert('assists', (v) => (v as num).toInt()),
        level: $checkedConvert('level', (v) => (v as num?)?.toInt() ?? 0),
        tier: $checkedConvert('tier', (v) => (v as num?)?.toInt() ?? 0),
        score: $checkedConvert('score', (v) => (v as num?)?.toInt() ?? 0),
        shots: $checkedConvert(
          'shots',
          (v) => v == null ? null : Shots.fromJson(v as Map<String, dynamic>),
        ),
        damage: $checkedConvert(
          'damage',
          (v) => v == null ? null : Damage.fromJson(v as Map<String, dynamic>),
        ),
        name: $checkedConvert('name', (v) => v as String?),
        tag: $checkedConvert('tag', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$PlayerStatsToJson(PlayerStats instance) =>
    <String, dynamic>{
      'puuid': instance.puuid,
      'team': instance.team,
      'character': instance.character.toJson(),
      'kills': instance.kills,
      'deaths': instance.deaths,
      'assists': instance.assists,
      'level': instance.level,
      'tier': instance.tier,
      'score': instance.score,
      'shots': instance.shots?.toJson(),
      'damage': instance.damage?.toJson(),
      'name': instance.name,
      'tag': instance.tag,
    };

Shots _$ShotsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Shots', json, ($checkedConvert) {
      final val = Shots(
        head: $checkedConvert('head', (v) => (v as num?)?.toInt() ?? 0),
        body: $checkedConvert('body', (v) => (v as num?)?.toInt() ?? 0),
        leg: $checkedConvert('leg', (v) => (v as num?)?.toInt() ?? 0),
      );
      return val;
    });

Map<String, dynamic> _$ShotsToJson(Shots instance) => <String, dynamic>{
  'head': instance.head,
  'body': instance.body,
  'leg': instance.leg,
};

Damage _$DamageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Damage', json, ($checkedConvert) {
      final val = Damage(
        made: $checkedConvert('made', (v) => (v as num?)?.toInt() ?? 0),
        received: $checkedConvert('received', (v) => (v as num?)?.toInt() ?? 0),
      );
      return val;
    });

Map<String, dynamic> _$DamageToJson(Damage instance) => <String, dynamic>{
  'made': instance.made,
  'received': instance.received,
};

TeamScore _$TeamScoreFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TeamScore', json, ($checkedConvert) {
      final val = TeamScore(
        red: $checkedConvert('red', (v) => (v as num).toInt()),
        blue: $checkedConvert('blue', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$TeamScoreToJson(TeamScore instance) => <String, dynamic>{
  'red': instance.red,
  'blue': instance.blue,
};
