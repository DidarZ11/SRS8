import 'package:json_annotation/json_annotation.dart';

part 'content.g.dart';

/// Ответ `GET /valorant/v1/content` — справочник агентов и карт.
@JsonSerializable(checked: true, explicitToJson: true)
class ContentResponse {
  const ContentResponse({required this.status, required this.data});

  factory ContentResponse.fromJson(Map<String, dynamic> json) => _$ContentResponseFromJson(json);

  final int status;
  final GameContent data;

  Map<String, dynamic> toJson() => _$ContentResponseToJson(this);
}

@JsonSerializable(checked: true, explicitToJson: true)
class GameContent {
  const GameContent({this.version, this.characters = const [], this.maps = const []});

  factory GameContent.fromJson(Map<String, dynamic> json) => _$GameContentFromJson(json);

  final String? version;
  final List<ContentItem> characters;
  final List<ContentItem> maps;

  /// Играбельные агенты, отсортированные по имени (без служебной записи «Null UI Data!»).
  List<String> get agentNames {
    final names = characters
        .where((c) => c.id != null && !c.name.toLowerCase().contains('null'))
        .map((c) => c.name)
        .toSet()
        .toList()
      ..sort();
    return names;
  }

  Map<String, dynamic> toJson() => _$GameContentToJson(this);
}

@JsonSerializable(checked: true)
class ContentItem {
  const ContentItem({required this.name, this.id, this.assetName});

  factory ContentItem.fromJson(Map<String, dynamic> json) => _$ContentItemFromJson(json);

  final String name;
  final String? id;
  final String? assetName;

  Map<String, dynamic> toJson() => _$ContentItemToJson(this);
}
