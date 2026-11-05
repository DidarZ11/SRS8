import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/error/app_exception.dart';
import '../../data/models/match_details.dart';
import '../../data/models/note.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/repositories/notes_repository.dart';
import 'resource.dart';

class MatchDetailsState extends Equatable {
  const MatchDetailsState({
    this.details = const Resource.loading(),
    this.notes = const Resource.loading(),
  });

  /// Детали матча (HenrikDev) и заметки (свой сервер) грузятся независимо.
  final Resource<MatchDetails> details;
  final Resource<List<Note>> notes;

  MatchDetailsState copyWith({Resource<MatchDetails>? details, Resource<List<Note>>? notes}) =>
      MatchDetailsState(details: details ?? this.details, notes: notes ?? this.notes);

  @override
  List<Object?> get props => [details, notes];
}

class MatchDetailsCubit extends Cubit<MatchDetailsState> {
  MatchDetailsCubit({
    required this._matches,
    required this._notes,
    required this.region,
    required this.matchId,
  }) : super(const MatchDetailsState());

  final MatchRepository _matches;
  final NotesRepository _notes;
  final String region;
  final String matchId;

  Future<void> load() => Future.wait([loadDetails(), loadNotes()]);

  Future<void> loadDetails() async {
    final cached = _matches.cachedMatch(matchId);
    emit(state.copyWith(
      details: cached != null ? Resource.cached(cached.data, cached.savedAt, refreshing: true) : const Resource.loading(),
    ));
    try {
      final details = await _matches.fetchMatch(region, matchId);
      if (!isClosed) emit(state.copyWith(details: Resource.success(details)));
    } on AppException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        details: cached != null ? Resource.cached(cached.data, cached.savedAt, error: e) : Resource.error(e),
      ));
    }
  }

  Future<void> loadNotes() async {
    final cached = _notes.cachedNotes(matchId);
    emit(state.copyWith(
      notes: cached != null ? Resource.cached(cached.data, cached.savedAt, refreshing: true) : const Resource.loading(),
    ));
    try {
      final notes = await _notes.fetchNotes(matchId);
      if (isClosed) return;
      emit(state.copyWith(notes: notes.isEmpty ? Resource.empty(notes) : Resource.success(notes)));
    } on AppException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        notes: cached != null ? Resource.cached(cached.data, cached.savedAt, error: e) : Resource.error(e),
      ));
    }
  }

  /// Созданная заметка сразу появляется в списке с пометкой «создано локально».
  void addLocalNote(Note note) {
    final current = state.notes.data ?? const <Note>[];
    final updated = [note, ...current.where((n) => n.id != note.id)];
    final notes = state.notes;
    emit(state.copyWith(
      notes: notes.status == ViewStatus.cached
          ? Resource.cached(updated, notes.cachedAt!, refreshing: notes.refreshing, error: notes.error)
          : Resource.success(updated),
    ));
  }
}
