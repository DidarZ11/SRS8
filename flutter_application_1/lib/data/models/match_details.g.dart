// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchDetailsResponse _$MatchDetailsResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MatchDetailsResponse', json, ($checkedConvert) {
  final val = MatchDetailsResponse(
    status: $checkedConvert('status', (v) => (v as num).toInt()),
    data: $checkedConvert(
      'data',
      (v) => MatchDetails.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$MatchDetailsResponseToJson(
  MatchDetailsResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'data': instance.data.toJson(),
};

MatchDetails _$MatchDetailsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MatchDetails', json, ($checkedConvert) {
      final val = MatchDetails(
        metadata: $checkedConvert(
          'metadata',
          (v) => MatchMetadata.fromJson(v as Map<String, dynamic>),
        ),
        players: $checkedConvert(
          'players',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => MatchPlayer.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [],
        ),
        teams: $checkedConvert(
          'teams',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => MatchTeam.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [],
        ),
      );
      return val;
    });

Map<String, dynamic> _$MatchDetailsToJson(MatchDetails instance) =>
    <String, dynamic>{
      'metadata': instance.metadata.toJson(),
      'players': instance.players.map((e) => e.toJson()).toList(),
      'teams': instance.teams.map((e) => e.toJson()).toList(),
    };

MatchMetadata _$MatchMetadataFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'MatchMetadata',
      json,
      ($checkedConvert) {
        final val = MatchMetadata(
          matchId: $checkedConvert('match_id', (v) => v as String),
          map: $checkedConvert(
            'map',
            (v) => IdName.fromJson(v as Map<String, dynamic>),
          ),
          startedAt: $checkedConvert(
            'started_at',
            (v) => DateTime.parse(v as String),
          ),
          queue: $checkedConvert(
            'queue',
            (v) => MatchQueue.fromJson(v as Map<String, dynamic>),
          ),
          gameLengthInMs: $checkedConvert(
            'game_length_in_ms',
            (v) => (v as num?)?.toInt(),
          ),
          region: $checkedConvert('region', (v) => v as String?),
          cluster: $checkedConvert('cluster', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'matchId': 'match_id',
        'startedAt': 'started_at',
        'gameLengthInMs': 'game_length_in_ms',
      },
    );

Map<String, dynamic> _$MatchMetadataToJson(MatchMetadata instance) =>
    <String, dynamic>{
      'match_id': instance.matchId,
      'map': instance.map.toJson(),
      'started_at': instance.startedAt.toIso8601String(),
      'queue': instance.queue.toJson(),
      'game_length_in_ms': instance.gameLengthInMs,
      'region': instance.region,
      'cluster': instance.cluster,
    };

MatchQueue _$MatchQueueFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MatchQueue', json, ($checkedConvert) {
      final val = MatchQueue(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String?),
        modeType: $checkedConvert('mode_type', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'modeType': 'mode_type'});

Map<String, dynamic> _$MatchQueueToJson(MatchQueue instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'mode_type': instance.modeType,
    };

MatchPlayer _$MatchPlayerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MatchPlayer', json, ($checkedConvert) {
  final val = MatchPlayer(
    puuid: $checkedConvert('puuid', (v) => v as String),
    name: $checkedConvert('name', (v) => v as String),
    tag: $checkedConvert('tag', (v) => v as String),
    teamId: $checkedConvert('team_id', (v) => v as String),
    agent: $checkedConvert(
      'agent',
      (v) => IdName.fromJson(v as Map<String, dynamic>),
    ),
    stats: $checkedConvert(
      'stats',
      (v) => MatchPlayerStats.fromJson(v as Map<String, dynamic>),
    ),
    tier: $checkedConvert(
      'tier',
      (v) => v == null ? null : TierRef.fromJson(v as Map<String, dynamic>),
    ),
    accountLevel: $checkedConvert('account_level', (v) => (v as num?)?.toInt()),
  );
  return val;
}, fieldKeyMap: const {'teamId': 'team_id', 'accountLevel': 'account_level'});

Map<String, dynamic> _$MatchPlayerToJson(MatchPlayer instance) =>
    <String, dynamic>{
      'puuid': instance.puuid,
      'name': instance.name,
      'tag': instance.tag,
      'team_id': instance.teamId,
      'agent': instance.agent.toJson(),
      'stats': instance.stats.toJson(),
      'tier': instance.tier?.toJson(),
      'account_level': instance.accountLevel,
    };

MatchPlayerStats _$MatchPlayerStatsFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MatchPlayerStats', json, ($checkedConvert) {
  final val = MatchPlayerStats(
    score: $checkedConvert('score', (v) => (v as num).toInt()),
    kills: $checkedConvert('kills', (v) => (v as num).toInt()),
    deaths: $checkedConvert('deaths', (v) => (v as num).toInt()),
    assists: $checkedConvert('assists', (v) => (v as num).toInt()),
    headshots: $checkedConvert('headshots', (v) => (v as num?)?.toInt() ?? 0),
    bodyshots: $checkedConvert('bodyshots', (v) => (v as num?)?.toInt() ?? 0),
    legshots: $checkedConvert('legshots', (v) => (v as num?)?.toInt() ?? 0),
    damage: $checkedConvert(
      'damage',
      (v) => v == null ? null : DamageDealt.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$MatchPlayerStatsToJson(MatchPlayerStats instance) =>
    <String, dynamic>{
      'score': instance.score,
      'kills': instance.kills,
      'deaths': instance.deaths,
      'assists': instance.assists,
      'headshots': instance.headshots,
      'bodyshots': instance.bodyshots,
      'legshots': instance.legshots,
      'damage': instance.damage?.toJson(),
    };

DamageDealt _$DamageDealtFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DamageDealt', json, ($checkedConvert) {
      final val = DamageDealt(
        dealt: $checkedConvert('dealt', (v) => (v as num?)?.toInt() ?? 0),
        received: $checkedConvert('received', (v) => (v as num?)?.toInt() ?? 0),
      );
      return val;
    });

Map<String, dynamic> _$DamageDealtToJson(DamageDealt instance) =>
    <String, dynamic>{'dealt': instance.dealt, 'received': instance.received};

TierRef _$TierRefFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TierRef', json, ($checkedConvert) {
      final val = TierRef(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$TierRefToJson(TierRef instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

MatchTeam _$MatchTeamFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MatchTeam', json, ($checkedConvert) {
      final val = MatchTeam(
        teamId: $checkedConvert('team_id', (v) => v as String),
        won: $checkedConvert('won', (v) => v as bool),
        rounds: $checkedConvert(
          'rounds',
          (v) =>
              v == null ? null : TeamRounds.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    }, fieldKeyMap: const {'teamId': 'team_id'});

Map<String, dynamic> _$MatchTeamToJson(MatchTeam instance) => <String, dynamic>{
  'team_id': instance.teamId,
  'won': instance.won,
  'rounds': instance.rounds?.toJson(),
};

TeamRounds _$TeamRoundsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TeamRounds', json, ($checkedConvert) {
      final val = TeamRounds(
        won: $checkedConvert('won', (v) => (v as num?)?.toInt() ?? 0),
        lost: $checkedConvert('lost', (v) => (v as num?)?.toInt() ?? 0),
      );
      return val;
    });

Map<String, dynamic> _$TeamRoundsToJson(TeamRounds instance) =>
    <String, dynamic>{'won': instance.won, 'lost': instance.lost};
