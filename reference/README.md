# Đối chiếu ToDoListV3 → project hiện tại

## Kết quả quét (so sánh `ToDoListV3/ToDoList` với root project)

- **Chỉ có 1 file “thiếu” theo đúng đường dẫn:** `lib/firebase_options.dart` (FlutterFire CLI, key hardcode trong file).
- Project hiện tại **không dùng file đó nữa:** dùng `firebase.env` + `--dart-define-from-file` và `lib/core/config/firebase/firebase_options.dart` để an toàn khi đẩy GitHub.

Bản sao tham chiếu từ V3 nằm tại:

- `reference/v3_lib/firebase_options.dart`

**Không** import file này vào `main.dart` trừ khi bạn chủ động đổi lại kiến trúc (sẽ trùng với `firebase.env`).

## Các file cùng tên nhưng nội dung khác

Bản mới đã chỉnh UX / Firebase / nhóm / đăng nhập so với V3, ví dụ:

- `main.dart` (không còn `signOut` mỗi lần mở app; có xử lý lỗi khởi tạo Firebase)
- `application/app_controller.dart`, `firebase_auth_repository.dart`, `auth_repository.dart`
- `features/groups/*`, `features/tasks/*`, `features/auth/login_screen.dart`
- v.v.

Nếu cần **một phần logic cũ** từ V3, nên copy có chọn lọc từng đoạn, **không** ghi đè cả file mới.

## Thư mục `ToDoListV3`

Giữ local để đối chiếu được; nếu không muốn đưa lên Git, thêm vào `.gitignore`:

```
ToDoListV3/
```
