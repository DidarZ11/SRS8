import 'package:dio/dio.dart';
import 'package:flutter_application_1/core/error/app_exception.dart';
import 'package:flutter_application_1/data/remote/henrik_api.dart';
import 'package:flutter_application_1/data/repositories/match_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
// ignore: implementation_imports — тип колбэка не экспортируется пакетом.
import 'package:http_mock_adapter/src/types.dart' show MockServerCallback;

import 'helpers/fixtures.dart';

void main() {
  final hive = TestHive();
  late Dio dio;
  late DioAdapter adapter;
  late MatchRepositoryImpl repository;

  setUp(() async {
    await hive.setUp();
    (dio, adapter) = mockDio();
    repository = MatchRepositoryImpl(api: HenrikApi(dio), cache: await hive.openCache());
  });

  tearDown(hive.tearDown);

  // Мокаем запрос по относительному пути Retrofit и query-параметрам.
  void onMatches(MockServerCallback reply, {int page = 1, int size = 2, String? map}) => adapter.onGet(
        storedMatchesPath,
        reply,
        queryParameters: {'page': page, 'size': size, 'map': ?map},
      );

  Future<MatchesPage> fetch({int page = 1, MatchFilter filter = const MatchFilter()}) =>
      repository.fetchMatches(testPlayer, filter, page: page, size: 2);

  test('3. успешная загрузка матчей через репозиторий + запись в кэш', () async {
    onMatches((s) => s.reply(200,
        storedMatchesResponse([storedMatchJson(id: 'a'), storedMatchJson(id: 'b')], total: 5)));

    final page = await fetch();

    expect(page.items.map((m) => m.id), ['a', 'b']);
    expect(page.hasMore, isTrue);
    final cached = repository.cachedMatches(testPlayer, const MatchFilter());
    expect(cached?.data.map((m) => m.id), ['a', 'b']);
  });

  test('следующая страница дописывается в кэш без дубликатов', () async {
    onMatches((s) => s.reply(200, storedMatchesResponse([storedMatchJson(id: 'a'), storedMatchJson(id: 'b')])));
    onMatches((s) => s.reply(200, storedMatchesResponse([storedMatchJson(id: 'b'), storedMatchJson(id: 'c')])),
        page: 2);

    await fetch();
    await fetch(page: 2);

    expect(repository.cachedMatches(testPlayer, const MatchFilter())!.data.map((m) => m.id), ['a', 'b', 'c']);
  });

  test('4. ошибка сервера → ServerException, последний успешный кэш сохраняется', () async {
    onMatches((s) => s.reply(200, storedMatchesResponse([storedMatchJson(id: 'a')])));
    await fetch();

    onMatches((s) => s.reply(500, {
          'errors': [
            {'code': 0, 'message': 'boom', 'status': 500},
          ],
        }));

    await expectLater(
      fetch(),
      throwsA(isA<ServerException>().having((e) => e.statusCode, 'statusCode', 500)),
    );
    expect(repository.cachedMatches(testPlayer, const MatchFilter())!.data.single.id, 'a');
  });

  test('кэши разных фильтров не смешиваются', () async {
    onMatches((s) => s.reply(200, storedMatchesResponse([storedMatchJson(id: 'all')])));
    onMatches((s) => s.reply(200, storedMatchesResponse([storedMatchJson(id: 'bind', map: 'Bind')])), map: 'Bind');

    await fetch();
    await fetch(filter: const MatchFilter(map: 'Bind'));

    expect(repository.cachedMatches(testPlayer, const MatchFilter())!.data.single.id, 'all');
    expect(repository.cachedMatches(testPlayer, const MatchFilter(map: 'Bind'))!.data.single.id, 'bind');
  });

  group('единый механизм ошибок', () {
    Future<AppException> errorFor(MockServerCallback reply) async {
      onMatches(reply);
      try {
        await fetch();
      } on AppException catch (e) {
        return e;
      }
      fail('ожидалась ошибка');
    }

    // RetryInterceptor повторит GET именно с этими options, поэтому они совпадают с исходным запросом.
    DioException dioError(DioExceptionType type) => DioException(
          requestOptions: RequestOptions(path: storedMatchesPath, queryParameters: {'page': 1, 'size': 2}),
          type: type,
        );

    test('нет соединения', () async {
      expect(await errorFor((s) => s.throws(0, dioError(DioExceptionType.connectionError))),
          isA<NoConnectionException>());
    });

    test('таймаут', () async {
      expect(await errorFor((s) => s.throws(0, dioError(DioExceptionType.receiveTimeout))),
          isA<TimeoutException>());
    });

    test('HTTP 4xx (например, 429 — лимит API)', () async {
      final e = await errorFor((s) => s.reply(429, {'errors': []}));
      expect(e, isA<ClientException>().having((e) => e.statusCode, 'code', 429));
      expect(e.userMessage, contains('лимит'));
    });

    test('некорректный JSON (нет обязательного поля)', () async {
      final broken = storedMatchesResponse([storedMatchJson(id: 'a')]);
      ((broken['data'] as List).first['meta'] as Map).remove('id');
      expect(await errorFor((s) => s.reply(200, broken)), isA<ParsingException>());
    });

    test('технические подробности не попадают в текст для пользователя', () async {
      final e = await errorFor((s) => s.reply(503, {'errors': []}));
      expect(e, isA<ServerException>());
      expect(e.userMessage, isNot(contains('503')));
      expect(e.technicalDetails, contains('503'));
    });
  });

  test('ключ API добавляется заголовком Authorization только для HenrikDev', () async {
    final captured = <RequestOptions>[];
    dio.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
      captured.add(o);
      h.reject(DioException(requestOptions: o, type: DioExceptionType.cancel));
    }));

    Future<void> send(String path) => dio.get<void>(path).then((_) {}, onError: (_) {});
    await send('/valorant/v1/content');
    await send('http://localhost:3000/notes');

    expect(captured[0].headers['Authorization'], 'HDEV-test');
    expect(captured[0].headers['X-Request-Id'], isNotNull);
    expect(captured[1].headers.containsKey('Authorization'), isFalse);
  });
}
