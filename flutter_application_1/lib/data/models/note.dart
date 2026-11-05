import 'package:json_annotation/json_annotation.dart';

part 'note.g.dart';

/// Заметка к матчу — хранится на своём json-server (Docker).
/// Аналог комментария к посту + сущность, которую создаёт POST-запрос.
@JsonSerializable(checked: true)
class Note {
  const Note({
    required this.id,
    required this.agent,
    required this.title,
    required this.body,
    this.matchId,
    this.createdAt,
    this.isLocal = false,
  });

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  final int id;
  final String? matchId;
  final String agent;
  final String title;
  @JsonKey(defaultValue: '')
  final String body;
  final DateTime? createdAt;

  /// true — объект получен из ответа POST и добавлен в список локально,
  /// а не загружен из списка на сервере. Сервер это поле не получает.
  @JsonKey(defaultValue: false)
  final bool isLocal;

  Note copyWith({bool? isLocal}) => Note(
        id: id,
        agent: agent,
        title: title,
        body: body,
        matchId: matchId,
        createdAt: createdAt,
        isLocal: isLocal ?? this.isLocal,
      );

  Map<String, dynamic> toJson() => _$NoteToJson(this);
}

/// Тело запроса `POST /notes`.
@JsonSerializable(includeIfNull: false)
class CreateNoteRequest {
  const CreateNoteRequest({
    required this.agent,
    required this.title,
    required this.body,
    required this.createdAt,
    this.matchId,
  });

  factory CreateNoteRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateNoteRequestFromJson(json);

  final String? matchId;
  final String agent;
  final String title;
  final String body;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$CreateNoteRequestToJson(this);
}
