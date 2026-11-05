import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_application_1/core/network/api_interceptor.dart';
import 'package:flutter_application_1/core/network/retry_interceptor.dart';
import 'package:flutter_application_1/data/local/app_cache.dart';
import 'package:flutter_application_1/data/models/player_id.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

const testPlayer = PlayerId(region: 'eu', name: 'Tester', tag: 'EUW');

Map<String, dynamic> storedMatchJson({
  required String id,
  String map = 'Ascent',
  String agent = 'Jett',
  String mode = 'Competitive',
  String startedAt = '2026-10-20T18:00:00.000Z',
  int kills = 20,
}) =>
    {
      'meta': {
        'id': id,
        'map': {'id': 'map-$map', 'name': map},
        'version': 'release-11.08',
        'mode': mode,
        'started_at': startedAt,
        'season': {'id': 'season-1', 'short': 'e11a1'},
        'region': 'eu',
        'cluster': null,
      },
      'stats': {
        'puuid': 'puuid-1',
        'team': 'Red',
        'level': 120,
        'character': {'id': 'agent-$agent', 'name': agent},
        'tier': 15,
        'score': 4500,
        'kills': kills,
        'deaths': 15,
        'assists': 5,
        'shots': {'head': 30, 'body': 60, 'leg': 10},
        'damage': {'made': 3200, 'received': 2800},
      },
      'teams': {'red': 13, 'blue': 9},
    };

Map<String, dynamic> storedMatchesResponse(List<Map<String, dynamic>> items, {int total = 100}) => {
      'status': 200,
      'results': {'total': total, 'returned': items.length, 'before': 0, 'after': 0},
      'data': items,
    };

/// Путь Retrofit-запроса списка матчей для [testPlayer].
const storedMatchesPath = '/valorant/v1/stored-matches/eu/Tester/EUW';

/// Dio, настроенный как в приложении (интерцепторы), но с mock-адаптером вместо сети.
(Dio, DioAdapter) mockDio({Duration retryDelay = Duration.zero}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.henrikdev.xyz'));
  dio.interceptors
    ..add(ApiInterceptor(apiKey: 'HDEV-test', henrikHost: 'api.henrikdev.xyz'))
    ..add(RetryInterceptor(dio: dio, baseDelay: retryDelay));
  final adapter = DioAdapter(dio: dio);
  return (dio, adapter);
}

/// Hive во временной папке — тесты не трогают данные приложения.
class TestHive {
  late Directory _dir;
  int _boxCounter = 0;

  Future<void> setUp() async {
    _dir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(_dir.path);
  }

  Future<AppCache> openCache() => AppCache.open(name: 'cache_${_boxCounter++}');

  Future<void> tearDown() async {
    await Hive.close();
    await _dir.delete(recursive: true);
  }
}
