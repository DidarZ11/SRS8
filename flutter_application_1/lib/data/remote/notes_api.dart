import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/note.dart';

part 'notes_api.g.dart';

@RestApi()
abstract class NotesApi {
  factory NotesApi(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _NotesApi;

  @GET('/notes')
  Future<List<Note>> getNotes({
    @Query('matchId') String? matchId,
    @Query('_sort') String? sort,
    @Query('_order') String? order,
  });

  @POST('/notes')
  Future<Note> createNote(@Body() CreateNoteRequest request);
}
