import 'package:json_annotation/json_annotation.dart';

part 'common.g.dart';

/// Вложенный объект вида `{"id": "...", "name": "..."}` — карта, агент, сезон.
@JsonSerializable(checked: true)
class IdName {
  const IdName({required this.id, required this.name});

  factory IdName.fromJson(Map<String, dynamic> json) => _$IdNameFromJson(json);

  final String id;
  final String name;

  Map<String, dynamic> toJson() => _$IdNameToJson(this);
}
