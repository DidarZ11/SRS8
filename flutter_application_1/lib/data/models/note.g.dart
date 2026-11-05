// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Note', json, ($checkedConvert) {
      final val = Note(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        agent: $checkedConvert('agent', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        body: $checkedConvert('body', (v) => v as String? ?? ''),
        matchId: $checkedConvert('matchId', (v) => v as String?),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        isLocal: $checkedConvert('isLocal', (v) => v as bool? ?? false),
      );
      return val;
    });

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
  'id': instance.id,
  'matchId': instance.matchId,
  'agent': instance.agent,
  'title': instance.title,
  'body': instance.body,
  'createdAt': instance.createdAt?.toIso8601String(),
  'isLocal': instance.isLocal,
};

CreateNoteRequest _$CreateNoteRequestFromJson(Map<String, dynamic> json) =>
    CreateNoteRequest(
      agent: json['agent'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      matchId: json['matchId'] as String?,
    );

Map<String, dynamic> _$CreateNoteRequestToJson(CreateNoteRequest instance) =>
    <String, dynamic>{
      'matchId': ?instance.matchId,
      'agent': instance.agent,
      'title': instance.title,
      'body': instance.body,
      'createdAt': instance.createdAt.toIso8601String(),
    };
