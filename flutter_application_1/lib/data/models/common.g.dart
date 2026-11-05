// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IdName _$IdNameFromJson(Map<String, dynamic> json) =>
    $checkedCreate('IdName', json, ($checkedConvert) {
      final val = IdName(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$IdNameToJson(IdName instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};
