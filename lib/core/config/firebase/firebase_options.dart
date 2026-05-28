import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kDebugMode, kIsWeb;

/// Firebase options: ưu tiên `--dart-define` / `--dart-define-from-file=firebase.env`.
/// Khi [kDebugMode] và không có define, dùng tạm giá trị dev (tiện F5 / `flutter run` không flag).
/// Bản release **phải** có đủ define hoặc build sẽ báo thiếu.
abstract final class AppFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      final FirebaseOptions o = web;
      _ensureRequired(o, 'WEB');
      return o;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final FirebaseOptions o = android;
        _ensureRequired(o, 'ANDROID');
        return o;
      case TargetPlatform.iOS:
        final FirebaseOptions o = ios;
        _ensureRequired(o, 'IOS');
        return o;
      case TargetPlatform.macOS:
        final FirebaseOptions o = macos;
        _ensureRequired(o, 'MACOS');
        return o;
      case TargetPlatform.windows:
        final FirebaseOptions o = windows;
        _ensureRequired(o, 'WINDOWS');
        return o;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase is not configured for linux in this project.',
        );
      default:
        throw UnsupportedError('Unsupported platform for Firebase.');
    }
  }

  /// Giá trị dev (trùng project todolist-92e3c) — chỉ dùng khi [kDebugMode] và env trống.
  static const String _dProjectId = 'todolist-92e3c';
  static const String _dSenderId = '1055155041163';
  static const String _dStorage = 'todolist-92e3c.firebasestorage.app';
  static const String _dDbUrl =
      'https://todolist-92e3c-default-rtdb.firebaseio.com';

  static const String _dWebKey = 'AIzaSyAnu80yk8-iDaBsChn5mzO6eCr9C8AtTdQ';
  static const String _dWebAppId = '1:1055155041163:web:9e49264ec66429b908758e';
  static const String _dAuthDomain = 'todolist-92e3c.firebaseapp.com';
  static const String _dWebMeasurement = 'G-R8GR00D7NC';

  static const String _dAndroidKey = 'AIzaSyBt9Rek5GeoUB02DFZV81fA7OIpzrZ-QYo';
  static const String _dAndroidAppId =
      '1:1055155041163:android:33dc7a5004f833c508758e';

  static const String _dIosKey = 'AIzaSyBrXdeylOmtE6Ez2PLaAptrP37FagqksB0';
  static const String _dIosAppId =
      '1:1055155041163:ios:5be9cbddde8153eb08758e';
  static const String _dIosBundle = 'com.example.todoList';

  static const String _dWinAppId =
      '1:1055155041163:web:bab04ed9be41163108758e';
  static const String _dWinMeasurement = 'G-46PPFD6DKV';

  static String _env(String key, String debugFallback) {
    final String v = _fromEnv(key);
    if (v.isNotEmpty) return v;
    if (kDebugMode) return debugFallback;
    return '';
  }

  static String _fromEnv(String name) {
    switch (name) {
      case 'FIREBASE_PROJECT_ID':
        return const String.fromEnvironment('FIREBASE_PROJECT_ID');
      case 'FIREBASE_MESSAGING_SENDER_ID':
        return const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
      case 'FIREBASE_STORAGE_BUCKET':
        return const String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
      case 'FIREBASE_DATABASE_URL':
        return const String.fromEnvironment('FIREBASE_DATABASE_URL');
      case 'FIREBASE_WEB_API_KEY':
        return const String.fromEnvironment('FIREBASE_WEB_API_KEY');
      case 'FIREBASE_WEB_APP_ID':
        return const String.fromEnvironment('FIREBASE_WEB_APP_ID');
      case 'FIREBASE_WEB_AUTH_DOMAIN':
        return const String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN');
      case 'FIREBASE_WEB_MEASUREMENT_ID':
        return const String.fromEnvironment('FIREBASE_WEB_MEASUREMENT_ID');
      case 'FIREBASE_ANDROID_API_KEY':
        return const String.fromEnvironment('FIREBASE_ANDROID_API_KEY');
      case 'FIREBASE_ANDROID_APP_ID':
        return const String.fromEnvironment('FIREBASE_ANDROID_APP_ID');
      case 'FIREBASE_IOS_API_KEY':
        return const String.fromEnvironment('FIREBASE_IOS_API_KEY');
      case 'FIREBASE_IOS_APP_ID':
        return const String.fromEnvironment('FIREBASE_IOS_APP_ID');
      case 'FIREBASE_IOS_BUNDLE_ID':
        return const String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');
      case 'FIREBASE_MACOS_API_KEY':
        return const String.fromEnvironment('FIREBASE_MACOS_API_KEY');
      case 'FIREBASE_MACOS_APP_ID':
        return const String.fromEnvironment('FIREBASE_MACOS_APP_ID');
      case 'FIREBASE_MACOS_BUNDLE_ID':
        return const String.fromEnvironment('FIREBASE_MACOS_BUNDLE_ID');
      case 'FIREBASE_WINDOWS_API_KEY':
        return const String.fromEnvironment('FIREBASE_WINDOWS_API_KEY');
      case 'FIREBASE_WINDOWS_APP_ID':
        return const String.fromEnvironment('FIREBASE_WINDOWS_APP_ID');
      case 'FIREBASE_WINDOWS_AUTH_DOMAIN':
        return const String.fromEnvironment('FIREBASE_WINDOWS_AUTH_DOMAIN');
      case 'FIREBASE_WINDOWS_MEASUREMENT_ID':
        return const String.fromEnvironment('FIREBASE_WINDOWS_MEASUREMENT_ID');
      default:
        return '';
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: _env('FIREBASE_WEB_API_KEY', _dWebKey),
        appId: _env('FIREBASE_WEB_APP_ID', _dWebAppId),
        messagingSenderId: _env('FIREBASE_MESSAGING_SENDER_ID', _dSenderId),
        projectId: _env('FIREBASE_PROJECT_ID', _dProjectId),
        authDomain: _env('FIREBASE_WEB_AUTH_DOMAIN', _dAuthDomain),
        storageBucket: _env('FIREBASE_STORAGE_BUCKET', _dStorage),
        measurementId: _env('FIREBASE_WEB_MEASUREMENT_ID', _dWebMeasurement),
        databaseURL: _env('FIREBASE_DATABASE_URL', _dDbUrl),
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: _env('FIREBASE_ANDROID_API_KEY', _dAndroidKey),
        appId: _env('FIREBASE_ANDROID_APP_ID', _dAndroidAppId),
        messagingSenderId: _env('FIREBASE_MESSAGING_SENDER_ID', _dSenderId),
        projectId: _env('FIREBASE_PROJECT_ID', _dProjectId),
        storageBucket: _env('FIREBASE_STORAGE_BUCKET', _dStorage),
        databaseURL: _env('FIREBASE_DATABASE_URL', _dDbUrl),
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: _env('FIREBASE_IOS_API_KEY', _dIosKey),
        appId: _env('FIREBASE_IOS_APP_ID', _dIosAppId),
        messagingSenderId: _env('FIREBASE_MESSAGING_SENDER_ID', _dSenderId),
        projectId: _env('FIREBASE_PROJECT_ID', _dProjectId),
        storageBucket: _env('FIREBASE_STORAGE_BUCKET', _dStorage),
        iosBundleId: _env('FIREBASE_IOS_BUNDLE_ID', _dIosBundle),
        databaseURL: _env('FIREBASE_DATABASE_URL', _dDbUrl),
      );

  static FirebaseOptions get macos => FirebaseOptions(
        apiKey: _env('FIREBASE_MACOS_API_KEY', _dIosKey),
        appId: _env('FIREBASE_MACOS_APP_ID', _dIosAppId),
        messagingSenderId: _env('FIREBASE_MESSAGING_SENDER_ID', _dSenderId),
        projectId: _env('FIREBASE_PROJECT_ID', _dProjectId),
        storageBucket: _env('FIREBASE_STORAGE_BUCKET', _dStorage),
        iosBundleId: _env('FIREBASE_MACOS_BUNDLE_ID', _dIosBundle),
        databaseURL: _env('FIREBASE_DATABASE_URL', _dDbUrl),
      );

  static FirebaseOptions get windows => FirebaseOptions(
        apiKey: _env('FIREBASE_WINDOWS_API_KEY', _dWebKey),
        appId: _env('FIREBASE_WINDOWS_APP_ID', _dWinAppId),
        messagingSenderId: _env('FIREBASE_MESSAGING_SENDER_ID', _dSenderId),
        projectId: _env('FIREBASE_PROJECT_ID', _dProjectId),
        authDomain: _env('FIREBASE_WINDOWS_AUTH_DOMAIN', _dAuthDomain),
        storageBucket: _env('FIREBASE_STORAGE_BUCKET', _dStorage),
        measurementId:
            _env('FIREBASE_WINDOWS_MEASUREMENT_ID', _dWinMeasurement),
        databaseURL: _env('FIREBASE_DATABASE_URL', _dDbUrl),
      );

  static void _ensureRequired(FirebaseOptions options, String platform) {
    final Map<String, String> required = <String, String>{
      'apiKey': options.apiKey,
      'appId': options.appId,
      'messagingSenderId': options.messagingSenderId,
      'projectId': options.projectId,
      'databaseURL': options.databaseURL ?? '',
    };
    final List<String> missing = required.entries
        .where((MapEntry<String, String> entry) => entry.value.trim().isEmpty)
        .map((MapEntry<String, String> entry) => entry.key)
        .toList();
    if (missing.isNotEmpty) {
      throw StateError(
        'Missing Firebase config for $platform: ${missing.join(', ')}. '
        'Chạy debug từ IDE hoặc thêm --dart-define-from-file=firebase.env '
        '(xem FIREBASE_SETUP.md).',
      );
    }
  }
}
