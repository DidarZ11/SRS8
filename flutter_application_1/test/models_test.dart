import 'package:flutter_application_1/core/error/app_exception.dart';
import 'package:flutter_application_1/data/models/match_details.dart';
import 'package:flutter_application_1/data/models/note.dart';
import 'package:flutter_application_1/data/models/stored_match.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fixtures.dart';

void main() {
  group('JSON → модель', () {
    test('1. StoredMatch успешно создаётся из JSON (с вложенными объектами)', () {
      final match = StoredMatch.fromJson(storedMatchJson(id: 'm1', map: 'Bind', agent: 'Sova'));

      expect(match.id, 'm1');
      expect(match.meta.map.name, 'Bind');
      expect(match.meta.startedAt, DateTime.utc(2026, 10, 20, 18));
      expect(match.meta.season?.short, 'e11a1');
      expect(match.stats.character.name, 'Sova');
      expect(match.stats.shots?.head, 30);
      expect(match.stats.headshotPercent, 30);
      expect(match.isWin, isTrue); // Red 13 : 9 Blue, игрок за Red
    });

    test('nullable и необязательные поля не ломают разбор', () {
      final json = storedMatchJson(id: 'm2');
      (json['meta'] as Map).remove('season');
      (json['stats'] as Map)
        ..remove('shots')
        ..remove('damage')
        ..remove('score');

      final match = StoredMatch.fromJson(json);

      expect(match.meta.season, isNull);
      expect(match.stats.shots, isNull);
      expect(match.stats.headshotPercent, isNull);
      expect(match.stats.score, 0);
    });

    test('отсутствие обязательного поля → ParsingException, а не падение', () {
      final json = storedMatchJson(id: 'm3');
      (json['meta'] as Map).remove('map');

      Object? error;
      try {
        StoredMatch.fromJson(json);
      } catch (e) {
        error = e;
      }

      expect(error, isNotNull);
      expect(ErrorMapper.map(error!), isA<ParsingException>());
    });

    test('MatchDetails: из большого ответа берутся только нужные поля', () {
      final details = MatchDetails.fromJson({
        'metadata': {
          'match_id': 'm1',
          'map': {'id': 'x', 'name': 'Lotus'},
          'started_at': '2026-10-20T18:00:00.000Z',
          'queue': {'id': 'competitive', 'name': 'Competitive', 'mode_type': 'Standard'},
          'game_length_in_ms': 2400000,
          'unknown_field': {'ignored': true},
        },
        'players': [
          {
            'puuid': 'p1',
            'name': 'Tester',
            'tag': 'EUW',
            'team_id': 'Red',
            'agent': {'id': 'a', 'name': 'Jett'},
            'stats': {'score': 5000, 'kills': 25, 'deaths': 10, 'assists': 3},
            'tier': {'id': 20, 'name': 'Platinum 3'},
          },
        ],
        'teams': [
          {'team_id': 'Red', 'won': true, 'rounds': {'won': 13, 'lost': 7}},
        ],
        'rounds': [],
        'kills': [],
      });

      expect(details.metadata.queue.modeType, 'Standard');
      expect(details.players.single.tier?.name, 'Platinum 3');
      expect(details.players.single.stats.headshots, 0);
      expect(details.teams.single.rounds?.won, 13);
    });
  });

  group('модель → JSON', () {
    test('2. StoredMatch преобразуется обратно в JSON без потерь', () {
      final source = storedMatchJson(id: 'm1');
      final match = StoredMatch.fromJson(source);

      final json = match.toJson();
      final again = StoredMatch.fromJson(json);

      expect(json['meta']['map'], {'id': 'map-Ascent', 'name': 'Ascent'});
      expect(json['meta']['started_at'], '2026-10-20T18:00:00.000Z');
      expect(json['stats']['shots'], {'head': 30, 'body': 60, 'leg': 10});
      expect(again.toJson(), json);
    });

    test('CreateNoteRequest не отправляет пустой matchId и служебные поля', () {
      final request = CreateNoteRequest(
        agent: 'Jett',
        title: 'Заголовок',
        body: 'Текст заметки',
        createdAt: DateTime.utc(2026, 10, 23),
      );

      expect(request.toJson(), {
        'agent': 'Jett',
        'title': 'Заголовок',
        'body': 'Текст заметки',
        'createdAt': '2026-10-23T00:00:00.000Z',
      });
    });
  });
}
