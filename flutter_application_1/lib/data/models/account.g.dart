// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountResponse _$AccountResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AccountResponse', json, ($checkedConvert) {
      final val = AccountResponse(
        status: $checkedConvert('status', (v) => (v as num).toInt()),
        data: $checkedConvert(
          'data',
          (v) => Account.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AccountResponseToJson(AccountResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data.toJson(),
    };

Account _$AccountFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Account',
  json,
  ($checkedConvert) {
    final val = Account(
      puuid: $checkedConvert('puuid', (v) => v as String),
      region: $checkedConvert('region', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      tag: $checkedConvert('tag', (v) => v as String),
      accountLevel: $checkedConvert(
        'account_level',
        (v) => (v as num?)?.toInt() ?? 0,
      ),
      card: $checkedConvert('card', (v) => v as String?),
      title: $checkedConvert('title', (v) => v as String?),
      updatedAt: $checkedConvert('updated_at', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'accountLevel': 'account_level',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
  'puuid': instance.puuid,
  'region': instance.region,
  'name': instance.name,
  'tag': instance.tag,
  'account_level': instance.accountLevel,
  'card': instance.card,
  'title': instance.title,
  'updated_at': instance.updatedAt,
};
