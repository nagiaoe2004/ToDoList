# Firebase Setup (Safe for GitHub)

Project reads Firebase config from `--dart-define` / `firebase.env`. Trong **debug** (`flutter run` debug hoặc F5), nếu không truyền define, app tự dùng tạm cấu hình dev (cùng project) để không bị màn trắng. **Release / profile** vẫn nên dùng `firebase.env` hoặc define đầy đủ.

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

## 4) Cách khuyến nghị cho cả nhóm (một file, không gõ dài)

1. Copy `firebase.env.example` → `firebase.env` (file này **không** commit lên Git).
2. Mở [Firebase Console](https://console.firebase.google.com) → Project của bạn → **Project settings** (biểu tượng bánh răng) → kéo xuống **Your apps**:
   - Chọn app **Web** để lấy: API Key, App ID, Auth domain, Measurement ID.
   - **Project number** thường dùng cho `FIREBASE_MESSAGING_SENDER_ID`.
   - **Project ID** → `FIREBASE_PROJECT_ID`.
   - **Storage** → bucket → `FIREBASE_STORAGE_BUCKET`.
   - **Realtime Database** → copy URL → `FIREBASE_DATABASE_URL` (dạng `https://xxx.firebaseio.com` hoặc `xxx-default-rtdb.firebaseio.com`).
3. Điền **hết** các dòng trong `firebase.env` (không để trống sau dấu `=`).
4. Chạy web (trong thư mục project):

```powershell
.\run_web.ps1
```

Hoặc:

```powershell
flutter run -d chrome --dart-define-from-file=firebase.env
```

**Quan trọng:** Mỗi máy phải dùng **cùng một** `firebase.env` (cùng project Firebase) thì tài khoản đăng nhập mới khớp. Nếu thiếu `--dart-define` / sai project, app có thể màn trắng lúc khởi động, hoặc báo sai mật khẩu dù nhập đúng (vì user không tồn tại trên project khác).

Gửi `firebase.env` cho bạn bè qua kênh riêng (không đưa lên GitHub).
