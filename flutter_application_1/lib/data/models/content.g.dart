// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentResponse _$ContentResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ContentResponse', json, ($checkedConvert) {
      final val = ContentResponse(
        status: $checkedConvert('status', (v) => (v as num).toInt()),
        data: $checkedConvert(
          'data',
          (v) => GameContent.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ContentResponseToJson(ContentResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data.toJson(),
    };

GameContent _$GameContentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GameContent', json, ($checkedConvert) {
      final val = GameContent(
        version: $checkedConvert('version', (v) => v as String?),
        characters: $checkedConvert(
          'characters',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => ContentItem.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              const [],
        ),
        maps: $checkedConvert(
          'maps',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => ContentItem.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              const [],
        ),
      );
      return val;
    });

Map<String, dynamic> _$GameContentToJson(GameContent instance) =>
    <String, dynamic>{
      'version': instance.version,
      'characters': instance.characters.map((e) => e.toJson()).toList(),
      'maps': instance.maps.map((e) => e.toJson()).toList(),
    };

ContentItem _$ContentItemFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ContentItem', json, ($checkedConvert) {
      final val = ContentItem(
        name: $checkedConvert('name', (v) => v as String),
        id: $checkedConvert('id', (v) => v as String?),
        assetName: $checkedConvert('assetName', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$ContentItemToJson(ContentItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'assetName': instance.assetName,
    };
