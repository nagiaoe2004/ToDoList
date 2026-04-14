# Firebase Setup (Safe for GitHub)

Project now reads Firebase config from `--dart-define` instead of hardcoding keys in source files.

## 1) Keep Firebase files local only

Do not commit:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `macos/Runner/GoogleService-Info.plist`

These are already ignored in `.gitignore`.

## 2) Required dart-define keys

Shared:

- `FIREBASE_PROJECT_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_STORAGE_BUCKET`
- `FIREBASE_DATABASE_URL`

Web:

- `FIREBASE_WEB_API_KEY`
- `FIREBASE_WEB_APP_ID`
- `FIREBASE_WEB_AUTH_DOMAIN`
- `FIREBASE_WEB_MEASUREMENT_ID`

Android:

- `FIREBASE_ANDROID_API_KEY`
- `FIREBASE_ANDROID_APP_ID`

iOS:

- `FIREBASE_IOS_API_KEY`
- `FIREBASE_IOS_APP_ID`
- `FIREBASE_IOS_BUNDLE_ID`

macOS:

- `FIREBASE_MACOS_API_KEY`
- `FIREBASE_MACOS_APP_ID`
- `FIREBASE_MACOS_BUNDLE_ID`

Windows:

- `FIREBASE_WINDOWS_API_KEY`
- `FIREBASE_WINDOWS_APP_ID`
- `FIREBASE_WINDOWS_AUTH_DOMAIN`
- `FIREBASE_WINDOWS_MEASUREMENT_ID`

## 3) Run example (PowerShell)

```powershell
flutter run `
  --dart-define=FIREBASE_PROJECT_ID=your-project-id `
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your-sender-id `
  --dart-define=FIREBASE_STORAGE_BUCKET=your-storage-bucket `
  --dart-define=FIREBASE_DATABASE_URL=https://your-project-default-rtdb.firebaseio.com `
  --dart-define=FIREBASE_WEB_API_KEY=... `
  --dart-define=FIREBASE_WEB_APP_ID=... `
  --dart-define=FIREBASE_WEB_AUTH_DOMAIN=... `
  --dart-define=FIREBASE_WEB_MEASUREMENT_ID=... `
  --dart-define=FIREBASE_ANDROID_API_KEY=... `
  --dart-define=FIREBASE_ANDROID_APP_ID=... `
  --dart-define=FIREBASE_IOS_API_KEY=... `
  --dart-define=FIREBASE_IOS_APP_ID=... `
  --dart-define=FIREBASE_IOS_BUNDLE_ID=com.example.todo_list `
  --dart-define=FIREBASE_MACOS_API_KEY=... `
  --dart-define=FIREBASE_MACOS_APP_ID=... `
  --dart-define=FIREBASE_MACOS_BUNDLE_ID=com.example.todo_list `
  --dart-define=FIREBASE_WINDOWS_API_KEY=... `
  --dart-define=FIREBASE_WINDOWS_APP_ID=... `
  --dart-define=FIREBASE_WINDOWS_AUTH_DOMAIN=... `
  --dart-define=FIREBASE_WINDOWS_MEASUREMENT_ID=...
```

If a required value is missing, app throws a clear startup error describing missing keys.
