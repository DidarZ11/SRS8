import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'api_interceptor.dart';
import 'retry_interceptor.dart';


class DioClient {
  DioClient({String apiKey = AppConfig.henrikApiKey, bool enableLogging = kDebugMode})
      : dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.henrikBaseUrl,
            connectTimeout: AppConfig.connectTimeout,
            receiveTimeout: AppConfig.receiveTimeout,
            sendTimeout: AppConfig.connectTimeout,
            contentType: Headers.jsonContentType,
            responseType: ResponseType.json,
          ),
        ) {
    dio.interceptors.add(
      ApiInterceptor(apiKey: apiKey, henrikHost: Uri.parse(AppConfig.henrikBaseUrl).host),
    );
    dio.interceptors.add(RetryInterceptor(dio: dio));
    if (enableLogging) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: false, // заголовок Authorization не попадает в лог
          requestBody: true,
          responseHeader: false,
          responseBody: false,
          logPrint: (o) => debugPrint('[dio] $o'),
        ),
      );
    }
  }

  final Dio dio;
}
