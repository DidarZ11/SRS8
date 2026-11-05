import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

/// Ответ `GET /valorant/v2/account/{name}/{tag}` — информация об «авторе» матчей.
@JsonSerializable(checked: true, explicitToJson: true)
class AccountResponse {
  const AccountResponse({required this.status, required this.data});

  factory AccountResponse.fromJson(Map<String, dynamic> json) => _$AccountResponseFromJson(json);

  final int status;
  final Account data;

  Map<String, dynamic> toJson() => _$AccountResponseToJson(this);
}

@JsonSerializable(checked: true, fieldRename: FieldRename.snake)
class Account {
  const Account({
    required this.puuid,
    required this.region,
    required this.name,
    required this.tag,
    this.accountLevel = 0,
    this.card,
    this.title,
    this.updatedAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  final String puuid;
  final String region;
  final String name;
  final String tag;
  @JsonKey(defaultValue: 0)
  final int accountLevel;
  final String? card;
  final String? title;
  final String? updatedAt;

  /// Картинка карточки игрока с публичного CDN valorant-api.com.
  String? get cardImageUrl =>
      card == null ? null : 'https://media.valorant-api.com/playercards/$card/smallart.png';

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}
