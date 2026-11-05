import 'dart:async' as async;
import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';


sealed class AppException implements Exception {
  const AppException({this.technicalDetails});

  final String? technicalDetails;

  String get userMessage;

  @override
  String toString() => '$runtimeType: ${technicalDetails ?? userMessage}';
}

class NoConnectionException extends AppException {
  const NoConnectionException({super.technicalDetails});

  @override
  String get userMessage => 'Нет подключения к интернету или сервер недоступен.';
}

class TimeoutException extends AppException {
  const TimeoutException({super.technicalDetails});

  @override
  String get userMessage => 'Сервер слишком долго не отвечает. Попробуйте ещё раз.';
}

/// HTTP 4xx.
class ClientException extends AppException {
  const ClientException(this.statusCode, {super.technicalDetails});

  final int statusCode;

  @override
  String get userMessage => switch (statusCode) {
        400 => 'Некорректный запрос. Проверьте Riot ID и регион.',
        401 || 403 => 'Нет доступа: проверьте API-ключ HenrikDev.',
        404 => 'Данные не найдены.',
        408 => 'Сервер слишком долго не отвечает.',
        429 => 'Слишком много запросов (лимит API). Подождите минуту.',
        _ => 'Ошибка запроса (код $statusCode).',
      };
}

/// HTTP 5xx.
class ServerException extends AppException {
  const ServerException(this.statusCode, {super.technicalDetails});

  final int statusCode;

  @override
  String get userMessage => 'На сервере произошла ошибка. Попробуйте позже.';
}

/// Некорректный JSON или отсутствует обязательное поле.
class ParsingException extends AppException {
  const ParsingException({super.technicalDetails});

  @override
  String get userMessage => 'Сервер вернул данные в неожиданном формате.';
}

/// Запрос отменён (например, пользователь сменил фильтр). В UI не показывается.
class CancelledException extends AppException {
  const CancelledException({super.technicalDetails});

  @override
  String get userMessage => 'Запрос отменён.';
}

class UnknownException extends AppException {
  const UnknownException({super.technicalDetails});

  @override
  String get userMessage => 'Что-то пошло не так. Попробуйте ещё раз.';
}

/// Централизованное преобразование любых исключений в [AppException].
/// Технические подробности пишутся в лог разработки, наружу уходит только тип.
class ErrorMapper {
  const ErrorMapper._();

  static AppException map(Object error, [StackTrace? stackTrace]) {
    final mapped = _map(error);
    if (mapped is! CancelledException) {
      developer.log(
        '${mapped.runtimeType}: ${mapped.technicalDetails}',
        name: 'ValorantExplorer.error',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return mapped;
  }

  static AppException _map(Object error) {
    if (error is AppException) return error;
    if (error is DioException) return _fromDio(error);
    if (error is SocketException) {
      return NoConnectionException(technicalDetails: error.toString());
    }
    if (error is async.TimeoutException) {
      return TimeoutException(technicalDetails: error.toString());
    }
    if (error is FormatException ||
        error is CheckedFromJsonException ||
        error is MissingRequiredKeysException ||
        error is DisallowedNullValueException ||
        error is TypeError) {
      return ParsingException(technicalDetails: error.toString());
    }
    return UnknownException(technicalDetails: error.toString());
  }

  static AppException _fromDio(DioException e) {
    // Ключ API никогда не попадает в лог: логируем только путь без query.
    final uri = e.requestOptions.uri.replace(query: '');
    final details = '${e.requestOptions.method} $uri → ${e.type.name} '
        '${e.response?.statusCode ?? ''} ${e.message ?? ''}';
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return TimeoutException(technicalDetails: details);
      case DioExceptionType.connectionError:
        return NoConnectionException(technicalDetails: details);
      case DioExceptionType.cancel:
        return CancelledException(technicalDetails: details);
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        if (code >= 500) return ServerException(code, technicalDetails: details);
        if (code >= 400) return ClientException(code, technicalDetails: details);
        return UnknownException(technicalDetails: details);
      case DioExceptionType.badCertificate:
        return UnknownException(technicalDetails: details);
      case DioExceptionType.unknown:
        final inner = e.error;
        if (inner is SocketException || inner is HttpException) {
          return NoConnectionException(technicalDetails: '$details | $inner');
        }
        if (inner is FormatException) {
          return ParsingException(technicalDetails: '$details | $inner');
        }
        return UnknownException(technicalDetails: '$details | $inner');
    }
  }
}
