// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_id.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerId _$PlayerIdFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PlayerId', json, ($checkedConvert) {
      final val = PlayerId(
        region: $checkedConvert('region', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        tag: $checkedConvert('tag', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$PlayerIdToJson(PlayerId instance) => <String, dynamic>{
  'region': instance.region,
  'name': instance.name,
  'tag': instance.tag,
};
