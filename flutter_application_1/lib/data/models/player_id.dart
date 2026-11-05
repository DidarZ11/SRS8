import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'player_id.g.dart';

/// Riot ID игрока, чьи матчи показывает приложение: `Name#Tag` + регион.
@JsonSerializable(checked: true)
class PlayerId extends Equatable {
  const PlayerId({required this.region, required this.name, required this.tag});

  factory PlayerId.fromJson(Map<String, dynamic> json) => _$PlayerIdFromJson(json);

  static const regions = ['eu', 'na', 'ap', 'kr', 'br', 'latam'];

  final String region;
  final String name;
  final String tag;

  String get riotId => '$name#$tag';

  /// Ключ для кэша: разные игроки не смешиваются.
  String get key => '$region/${name.toLowerCase()}/${tag.toLowerCase()}';

  Map<String, dynamic> toJson() => _$PlayerIdToJson(this);

  @override
  List<Object?> get props => [region, name.toLowerCase(), tag.toLowerCase()];
}
