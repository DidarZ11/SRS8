import 'package:dio/dio.dart';


class ApiInterceptor extends Interceptor {
  ApiInterceptor({required this.apiKey, required this.henrikHost});

  final String apiKey;
  final String henrikHost;

  int _counter = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept'] = 'application/json';
    options.headers['X-Client-Name'] = 'valorant-explorer';
    options.headers['X-Client-Version'] = '1.0.0';
    options.headers['X-Request-Id'] =
        '${DateTime.now().millisecondsSinceEpoch}-${_counter++}';

    if (options.uri.host == henrikHost && apiKey.isNotEmpty) {
      options.headers['Authorization'] = apiKey;
    }
    handler.next(options);
  }
}
