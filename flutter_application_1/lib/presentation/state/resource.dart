import 'package:equatable/equatable.dart';

import '../../core/error/app_exception.dart';

/// Состояния экрана из задания.
enum ViewStatus {
  /// Первичная загрузка, данных ещё нет.
  loading,

  /// Данные получены с сервера.
  success,

  /// Показаны сохранённые данные: обновление идёт или сервер недоступен.
  cached,

  /// Сервер ответил, но данных нет.
  empty,

  /// Ошибка и нечего показать.
  error,
}

/// Универсальное состояние «одного ресурса» (детали матча, заметки, профиль).
class Resource<T> extends Equatable {
  const Resource._({required this.status, this.data, this.error, this.cachedAt, this.refreshing = false});

  const Resource.loading() : this._(status: ViewStatus.loading);

  const Resource.success(T data) : this._(status: ViewStatus.success, data: data);

  const Resource.empty(T data) : this._(status: ViewStatus.empty, data: data);

  const Resource.error(AppException error) : this._(status: ViewStatus.error, error: error);

  /// [refreshing] = true — запрос к серверу ещё выполняется;
  /// [error] != null — сервер недоступен, показываем последний успешный результат.
  const Resource.cached(T data, DateTime savedAt, {bool refreshing = false, AppException? error})
      : this._(status: ViewStatus.cached, data: data, cachedAt: savedAt, refreshing: refreshing, error: error);

  final ViewStatus status;
  final T? data;
  final AppException? error;
  final DateTime? cachedAt;
  final bool refreshing;

  @override
  List<Object?> get props => [status, data, error, cachedAt, refreshing];
}
