import 'package:json_annotation/json_annotation.dart';

import 'common.dart';

part 'match_details.g.dart';

/// Ответ `GET /valorant/v4/match/{region}/{matchId}`.
/// Из большого ответа берём только нужные поля — остальные json_serializable игнорирует.
@JsonSerializable(checked: true, explicitToJson: true)
class MatchDetailsResponse {
  const MatchDetailsResponse({required this.status, required this.data});

  factory MatchDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$MatchDetailsResponseFromJson(json);

  final int status;
  final MatchDetails data;

  Map<String, dynamic> toJson() => _$MatchDetailsResponseToJson(this);
}

@JsonSerializable(checked: true, explicitToJson: true)
class MatchDetails {
  const MatchDetails({required this.metadata, required this.players, required this.teams});

  factory MatchDetails.fromJson(Map<String, dynamic> json) => _$MatchDetailsFromJson(json);

  final MatchMetadata metadata;
  @JsonKey(defaultValue: <MatchPlayer>[])
  final List<MatchPlayer> players;
  @JsonKey(defaultValue: <MatchTeam>[])
  final List<MatchTeam> teams;

  Map<String, dynamic> toJson() => _$MatchDetailsToJson(this);
}

@JsonSerializable(checked: true, explicitToJson: true, fieldRename: FieldRename.snake)
class MatchMetadata {
  const MatchMetadata({
    required this.matchId,
    required this.map,
    required this.startedAt,
    required this.queue,
    this.gameLengthInMs,
    this.region,
    this.cluster,
  });

  factory MatchMetadata.fromJson(Map<String, dynamic> json) => _$MatchMetadataFromJson(json);

  final String matchId;
  final IdName map;
  final DateTime startedAt;
  final MatchQueue queue;
  final int? gameLengthInMs;
  final String? region;
  final String? cluster;

  Map<String, dynamic> toJson() => _$MatchMetadataToJson(this);
}

@JsonSerializable(checked: true, fieldRename: FieldRename.snake)
class MatchQueue {
  const MatchQueue({required this.id, this.name, this.modeType});

  factory MatchQueue.fromJson(Map<String, dynamic> json) => _$MatchQueueFromJson(json);

  final String id;
  final String? name;
  final String? modeType;

  Map<String, dynamic> toJson() => _$MatchQueueToJson(this);
}

@JsonSerializable(checked: true, explicitToJson: true, fieldRename: FieldRename.snake)
class MatchPlayer {
  const MatchPlayer({
    required this.puuid,
    required this.name,
    required this.tag,
    required this.teamId,
    required this.agent,
    required this.stats,
    this.tier,
    this.accountLevel,
  });

  factory MatchPlayer.fromJson(Map<String, dynamic> json) => _$MatchPlayerFromJson(json);

  final String puuid;
  final String name;
  final String tag;
  final String teamId;
  final IdName agent;
  final MatchPlayerStats stats;
  final TierRef? tier;
  final int? accountLevel;

  Map<String, dynamic> toJson() => _$MatchPlayerToJson(this);
}

@JsonSerializable(checked: true, explicitToJson: true)
class MatchPlayerStats {
  const MatchPlayerStats({
    required this.score,
    required this.kills,
    required this.deaths,
    required this.assists,
    this.headshots = 0,
    this.bodyshots = 0,
    this.legshots = 0,
    this.damage,
  });

  factory MatchPlayerStats.fromJson(Map<String, dynamic> json) =>
      _$MatchPlayerStatsFromJson(json);

  final int score;
  final int kills;
  final int deaths;
  final int assists;
  @JsonKey(defaultValue: 0)
  final int headshots;
  @JsonKey(defaultValue: 0)
  final int bodyshots;
  @JsonKey(defaultValue: 0)
  final int legshots;
  final DamageDealt? damage;

  Map<String, dynamic> toJson() => _$MatchPlayerStatsToJson(this);
}

@JsonSerializable(checked: true)
class DamageDealt {
  const DamageDealt({this.dealt = 0, this.received = 0});

  factory DamageDealt.fromJson(Map<String, dynamic> json) => _$DamageDealtFromJson(json);

  @JsonKey(defaultValue: 0)
  final int dealt;
  @JsonKey(defaultValue: 0)
  final int received;

  Map<String, dynamic> toJson() => _$DamageDealtToJson(this);
}

@JsonSerializable(checked: true)
class TierRef {
  const TierRef({required this.id, required this.name});

  factory TierRef.fromJson(Map<String, dynamic> json) => _$TierRefFromJson(json);

  final int id;
  final String name;

  Map<String, dynamic> toJson() => _$TierRefToJson(this);
}

@JsonSerializable(checked: true, explicitToJson: true, fieldRename: FieldRename.snake)
class MatchTeam {
  const MatchTeam({required this.teamId, required this.won, this.rounds});

  factory MatchTeam.fromJson(Map<String, dynamic> json) => _$MatchTeamFromJson(json);

  final String teamId;
  final bool won;
  final TeamRounds? rounds;

  Map<String, dynamic> toJson() => _$MatchTeamToJson(this);
}

@JsonSerializable(checked: true)
class TeamRounds {
  const TeamRounds({this.won = 0, this.lost = 0});

  factory TeamRounds.fromJson(Map<String, dynamic> json) => _$TeamRoundsFromJson(json);

  @JsonKey(defaultValue: 0)
  final int won;
  @JsonKey(defaultValue: 0)
  final int lost;

  Map<String, dynamic> toJson() => _$TeamRoundsToJson(this);
}
