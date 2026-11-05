import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/error/app_exception.dart';
import '../../data/models/note.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/repositories/notes_repository.dart';
import 'resource.dart';

class NoteValidator {
  const NoteValidator._();

  static const titleMin = 5, titleMax = 100;
  static const bodyMin = 10, bodyMax = 1000;

  static String? title(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Введите заголовок';
    if (v.length < titleMin) return 'Минимум $titleMin символов';
    if (v.length > titleMax) return 'Максимум $titleMax символов';
    return null;
  }

  static String? body(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Введите текст заметки';
    if (v.length < bodyMin) return 'Минимум $bodyMin символов';
    if (v.length > bodyMax) return 'Максимум $bodyMax символов';
    return null;
  }

  static String? agent(String? value) => (value == null || value.isEmpty) ? 'Выберите агента' : null;
}

enum SubmitStatus { idle, submitting, success, failure }

class CreateNoteState extends Equatable {
  const CreateNoteState({
    this.agents = const Resource.loading(),
    this.submitStatus = SubmitStatus.idle,
    this.created,
    this.error,
  });

  /// Список агентов для выбора (аналог списка пользователей).
  final Resource<List<String>> agents;

  /// Статус отправки формы — не зависит от загрузки списка агентов.
  final SubmitStatus submitStatus;
  final Note? created;
  final AppException? error;

  bool get isSubmitting => submitStatus == SubmitStatus.submitting;

  @override
  List<Object?> get props => [agents, submitStatus, created, error];
}

class CreateNoteCubit extends Cubit<CreateNoteState> {
  CreateNoteCubit({required this._matches, required this._notes, this.matchId})
      : super(const CreateNoteState());

  final MatchRepository _matches;
  final NotesRepository _notes;
  final String? matchId;

  Future<void> loadAgents() async {
    final cached = _matches.cachedAgents();
    if (cached != null) {
      emit(_copy(agents: Resource.cached(cached.data, cached.savedAt, refreshing: true)));
    }
    try {
      final agents = await _matches.fetchAgents();
      if (!isClosed) emit(_copy(agents: Resource.success(agents)));
    } on AppException catch (e) {
      if (isClosed) return;
      emit(_copy(
        agents: cached != null ? Resource.cached(cached.data, cached.savedAt, error: e) : Resource.error(e),
      ));
    }
  }

  /// Возвращает созданную заметку или null. Повторный вызов во время запроса игнорируется.
  Future<Note?> submit({required String title, required String body, required String? agent}) async {
    if (state.isSubmitting) return null;
    if (NoteValidator.title(title) != null ||
        NoteValidator.body(body) != null ||
        NoteValidator.agent(agent) != null) {
      return null;
    }
    emit(CreateNoteState(agents: state.agents, submitStatus: SubmitStatus.submitting));
    try {
      final note = await _notes.createNote(CreateNoteRequest(
        matchId: matchId,
        agent: agent!,
        title: title.trim(),
        body: body.trim(),
        createdAt: DateTime.now().toUtc(),
      ));
      if (!isClosed) {
        emit(CreateNoteState(agents: state.agents, submitStatus: SubmitStatus.success, created: note));
      }
      return note;
    } on AppException catch (e) {
      if (!isClosed) {
        emit(CreateNoteState(agents: state.agents, submitStatus: SubmitStatus.failure, error: e));
      }
      return null;
    }
  }

  CreateNoteState _copy({Resource<List<String>>? agents}) => CreateNoteState(
        agents: agents ?? state.agents,
        submitStatus: state.submitStatus,
        created: state.created,
        error: state.error,
      );
}
