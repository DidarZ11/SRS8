import 'dart:convert';
import 'dart:developer' as developer;

import 'package:hive_ce/hive_ce.dart';


class CacheEntry<T> {
  const CacheEntry(this.data, this.savedAt);

  final T data;
  final DateTime savedAt;
}


class AppCache {
  AppCache(this._box);

  static const boxName = 'valorant_cache';

  static Future<AppCache> open({String name = boxName}) async =>
      AppCache(await Hive.openBox<String>(name));

  final Box<String> _box;

  Future<void> write(String key, Object? json) => _box.put(
        key,
        jsonEncode({'savedAt': DateTime.now().toIso8601String(), 'data': json}),
      );

  /// Возвращает null, если записи нет или она повреждена (тогда запись удаляется).
  CacheEntry<T>? read<T>(String key, T Function(dynamic json) decode) {
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CacheEntry(decode(map['data']), DateTime.parse(map['savedAt'] as String));
    } catch (e, st) {
      developer.log('corrupted cache "$key"', name: 'ValorantExplorer.cache', error: e, stackTrace: st);
      _box.delete(key);
      return null;
    }
  }

  Future<void> delete(String key) => _box.delete(key);

  Future<void> clear() => _box.clear();
}
