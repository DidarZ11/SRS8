import 'dart:io';

import 'package:flutter/foundation.dart';


class AppConfig {
  const AppConfig._();

  static const henrikBaseUrl = 'https://api.henrikdev.xyz';

  static const henrikApiKey = String.fromEnvironment('HENRIK_API_KEY');

  static const defaultRegion = String.fromEnvironment('PLAYER_REGION', defaultValue: 'eu');
  static const defaultName = String.fromEnvironment('PLAYER_NAME');
  static const defaultTag = String.fromEnvironment('PLAYER_TAG');

  static const _notesBaseUrl = String.fromEnvironment('NOTES_BASE_URL');

  /// Адрес json-server из Docker. Эмулятор Android видит хост-машину как 10.0.2.2.
  static String get notesBaseUrl {
    if (_notesBaseUrl.isNotEmpty) return _notesBaseUrl;
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  static const pageSize = 10;

  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 20);
}
