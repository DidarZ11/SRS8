import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/account.dart';
import '../models/content.dart';
import '../models/match_details.dart';
import '../models/stored_match.dart';

part 'henrik_api.g.dart';

/// HenrikDev VALORANT API (https://docs.henrikdev.xyz).
/// Ключ добавляет ApiInterceptor, здесь его нет.
@RestApi(baseUrl: 'https://api.henrikdev.xyz')
abstract class HenrikApi {
  factory HenrikApi(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _HenrikApi;

  
  @GET('/valorant/v1/stored-matches/{region}/{name}/{tag}')
  Future<StoredMatchesResponse> getStoredMatches(
    @Path('region') String region,
    @Path('name') String name,
    @Path('tag') String tag, {
    @Query('page') required int page,
    @Query('size') required int size,
    @Query('map') String? map,
    @Query('mode') String? mode,
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/valorant/v4/match/{region}/{matchId}')
  Future<MatchDetailsResponse> getMatch(
    @Path('region') String region,
    @Path('matchId') String matchId,
  );

  @GET('/valorant/v2/account/{name}/{tag}')
  Future<AccountResponse> getAccount(
    @Path('name') String name,
    @Path('tag') String tag,
  );

  @GET('/valorant/v1/content')
  Future<ContentResponse> getContent();
}
