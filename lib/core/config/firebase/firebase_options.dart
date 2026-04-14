import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Firebase options loaded from --dart-define (safe for public repos).
abstract final class AppFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      _ensureRequired(web, 'WEB');
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        _ensureRequired(android, 'ANDROID');
        return android;
      case TargetPlatform.iOS:
        _ensureRequired(ios, 'IOS');
        return ios;
      case TargetPlatform.macOS:
        _ensureRequired(macos, 'MACOS');
        return macos;
      case TargetPlatform.windows:
        _ensureRequired(windows, 'WINDOWS');
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase is not configured for linux in this project.',
        );
      default:
        throw UnsupportedError('Unsupported platform for Firebase.');
    }
  }

  static const String _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String _senderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const String _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );
  static const String _databaseUrl = String.fromEnvironment('FIREBASE_DATABASE_URL');

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_WEB_APP_ID'),
    messagingSenderId: _senderId,
    projectId: _projectId,
    authDomain: String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN'),
    storageBucket: _storageBucket,
    measurementId: String.fromEnvironment('FIREBASE_WEB_MEASUREMENT_ID'),
    databaseURL: _databaseUrl,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
    messagingSenderId: _senderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
    databaseURL: _databaseUrl,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_IOS_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_IOS_APP_ID'),
    messagingSenderId: _senderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
    iosBundleId: String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID'),
    databaseURL: _databaseUrl,
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_MACOS_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_MACOS_APP_ID'),
    messagingSenderId: _senderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
    iosBundleId: String.fromEnvironment('FIREBASE_MACOS_BUNDLE_ID'),
    databaseURL: _databaseUrl,
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_WINDOWS_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_WINDOWS_APP_ID'),
    messagingSenderId: _senderId,
    projectId: _projectId,
    authDomain: String.fromEnvironment('FIREBASE_WINDOWS_AUTH_DOMAIN'),
    storageBucket: _storageBucket,
    measurementId: String.fromEnvironment('FIREBASE_WINDOWS_MEASUREMENT_ID'),
    databaseURL: _databaseUrl,
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
        'Missing Firebase dart-define for $platform: ${missing.join(', ')}.',
      );
    }
  }
}
