import 'package:dio/dio.dart';
import 'package:flutter_application_1/core/error/app_exception.dart';
import 'package:flutter_application_1/data/models/note.dart';
import 'package:flutter_application_1/data/remote/notes_api.dart';
import 'package:flutter_application_1/data/repositories/notes_repository.dart';
import 'package:flutter_application_1/presentation/state/create_note_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'helpers/fixtures.dart';

void main() {
  final hive = TestHive();
  late DioAdapter adapter;
  late NotesRepositoryImpl repository;
  late List<RequestOptions> posts;

  setUp(() async {
    await hive.setUp();
    final (dio, a) = mockDio();
    adapter = a;
    posts = [];
    dio.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
      if (o.method == 'POST') posts.add(o);
      h.next(o);
    }));
    repository = NotesRepositoryImpl(
      api: NotesApi(dio, baseUrl: 'http://localhost:3000'),
      cache: await hive.openCache(),
    );
  });

  tearDown(hive.tearDown);

  CreateNoteRequest request() => CreateNoteRequest(
        matchId: 'm1',
        agent: 'Jett',
        title: 'Тренировка аима',
        body: 'Тренировать префайры на B-лонге',
        createdAt: DateTime.utc(2026, 10, 23, 8),
      );

  final serverNote = {
    'id': 101,
    'matchId': 'm1',
    'agent': 'Jett',
    'title': 'Тренировка аима',
    'body': 'Тренировать префайры на B-лонге',
    'createdAt': '2026-10-23T08:00:00.000Z',
  };

  group('POST через mock-адаптер Dio (без интернета)', () {
    test('созданная заметка возвращается с пометкой «создано локально»', () async {
      adapter.onPost('/notes', (s) => s.reply(201, serverNote), data: Matchers.any);

      final note = await repository.createNote(request());

      expect(note.id, 101);
      expect(note.isLocal, isTrue);
      expect(posts.single.uri.toString(), 'http://localhost:3000/notes');
      expect(posts.single.data, {
        'matchId': 'm1',
        'agent': 'Jett',
        'title': 'Тренировка аима',
        'body': 'Тренировать префайры на B-лонге',
        'createdAt': '2026-10-23T08:00:00.000Z',
      });
      // Заметка сохранилась в локальном списке матча.
      expect(repository.cachedNotes('m1')!.data.single.isLocal, isTrue);
    });

    test('после загрузки списка с сервера пометка «локально» исчезает', () async {
      adapter
        ..onPost('/notes', (s) => s.reply(201, serverNote), data: Matchers.any)
        ..onGet('/notes', (s) => s.reply(200, [serverNote]),
            queryParameters: {'matchId': 'm1', '_sort': 'createdAt', '_order': 'desc'});

      await repository.createNote(request());
      final notes = await repository.fetchNotes('m1');

      expect(notes, hasLength(1));
      expect(notes.single.isLocal, isFalse);
    });

    test('ошибка сервера при POST → ServerException; POST не повторяется автоматически', () async {
      adapter.onPost('/notes', (s) => s.reply(503, {'error': 'down'}), data: Matchers.any);

      await expectLater(repository.createNote(request()), throwsA(isA<ServerException>()));
      expect(posts, hasLength(1));
    });
  });

  group('валидация формы', () {
    test('title: обязательный, 5–100 символов', () {
      expect(NoteValidator.title(''), isNotNull);
      expect(NoteValidator.title('abcd'), isNotNull);
      expect(NoteValidator.title('abcde'), isNull);
      expect(NoteValidator.title('a' * 101), isNotNull);
    });

    test('body: обязательный, 10–1000 символов', () {
      expect(NoteValidator.body('   '), isNotNull);
      expect(NoteValidator.body('123456789'), isNotNull);
      expect(NoteValidator.body('1234567890'), isNull);
      expect(NoteValidator.body('a' * 1001), isNotNull);
    });

    test('агент обязателен', () {
      expect(NoteValidator.agent(null), isNotNull);
      expect(NoteValidator.agent('Jett'), isNull);
    });
  });
}
