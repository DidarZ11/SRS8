import '../../core/error/app_exception.dart';
import '../local/app_cache.dart';
import '../models/note.dart';
import '../remote/notes_api.dart';

abstract interface class NotesRepository {
  CacheEntry<List<Note>>? cachedNotes(String matchId);

  Future<List<Note>> fetchNotes(String matchId);

  Future<Note> createNote(CreateNoteRequest request);
}

class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl({required this._api, required this._cache});

  final NotesApi _api;
  final AppCache _cache;

  static String _serverKey(String matchId) => 'notes:$matchId';
  static String _localKey(String matchId) => 'notes-local:$matchId';

  List<Note> _read(String key) =>
      _cache.read(key, (json) => [for (final n in json as List) Note.fromJson(n as Map<String, dynamic>)])
          ?.data ??
      const [];

  @override
  CacheEntry<List<Note>>? cachedNotes(String matchId) {
    final server = _cache.read(
      _serverKey(matchId),
      (json) => [for (final n in json as List) Note.fromJson(n as Map<String, dynamic>)],
    );
    final local = _read(_localKey(matchId));
    if (server == null && local.isEmpty) return null;
    return CacheEntry(
      _merge(local, server?.data ?? const []),
      server?.savedAt ?? DateTime.now(),
    );
  }

  @override
  Future<List<Note>> fetchNotes(String matchId) async {
    try {
      final server = await _api.getNotes(matchId: matchId, sort: 'createdAt', order: 'desc');
      await _cache.write(_serverKey(matchId), [for (final n in server) n.toJson()]);

      // Локальная копия больше не нужна, если сервер уже вернул заметку в списке.
      final serverIds = server.map((n) => n.id).toSet();
      final local = _read(_localKey(matchId)).where((n) => !serverIds.contains(n.id)).toList();
      await _cache.write(_localKey(matchId), [for (final n in local) n.toJson()]);

      return _merge(local, server);
    } catch (e, st) {
      throw ErrorMapper.map(e, st);
    }
  }

  @override
  Future<Note> createNote(CreateNoteRequest request) async {
    try {
      final created = (await _api.createNote(request)).copyWith(isLocal: true);
      final matchId = created.matchId ?? request.matchId;
      if (matchId != null) {
        final local = [created, ..._read(_localKey(matchId))];
        await _cache.write(_localKey(matchId), [for (final n in local) n.toJson()]);
      }
      return created;
    } catch (e, st) {
      throw ErrorMapper.map(e, st);
    }
  }

  static List<Note> _merge(List<Note> local, List<Note> server) {
    final serverIds = server.map((n) => n.id).toSet();
    return [...local.where((n) => !serverIds.contains(n.id)), ...server];
  }
}
