# Bộ Test Case QA (Tiếng Việt)

Tài liệu này tổng hợp test case theo từng bảng dữ liệu, mỗi bảng 5 test case.

## 1) Bảng `users`

| Mã TC | Tiêu đề | Điều kiện tiên quyết | Bước thực hiện | Kết quả mong đợi | Mức ưu tiên | Loại |
|---|---|---|---|---|---|---|
| TC-USR-01 | Người dùng đã đăng nhập đọc hồ sơ của chính mình | Đăng nhập với `uid=A` | 1) Đăng nhập A 2) Đọc `users/A` | Đọc thành công | Cao | Dương tính |
| TC-USR-02 | Người dùng đã đăng nhập cập nhật hồ sơ của chính mình | Đăng nhập với `uid=A` | 1) Đăng nhập A 2) Cập nhật `users/A/name`, `users/A/phone` | Ghi thành công | Cao | Dương tính |
| TC-USR-03 | User A cập nhật hồ sơ user B | A đã đăng nhập, B tồn tại | 1) Đăng nhập A 2) Cập nhật `users/B/name` | Bị từ chối quyền | Cao | Âm tính |
| TC-USR-04 | Người dùng chưa đăng nhập đọc hồ sơ | Đã đăng xuất | 1) Đọc `users/A` | Bị từ chối quyền | Cao | Âm tính |
| TC-USR-05 | Truy vấn users theo email (index) | Đã đăng nhập, dữ liệu có trường email | 1) Truy vấn theo `email` | Truy vấn chạy ổn, không lỗi index/rule | Trung bình | Dương tính |

---

## 2) Bảng `userEmails`

| Mã TC | Tiêu đề | Điều kiện tiên quyết | Bước thực hiện | Kết quả mong đợi | Mức ưu tiên | Loại |
|---|---|---|---|---|---|---|
| TC-UEM-01 | Người dùng đã đăng nhập đọc ánh xạ email | Đã đăng nhập | 1) Đọc `userEmails` | Đọc thành công | Trung bình | Dương tính |
| TC-UEM-02 | Người dùng đã đăng nhập ghi ánh xạ email | Đã đăng nhập | 1) Ghi `userEmails/{email_chuan_hoa}=uid` | Ghi thành công | Trung bình | Dương tính |
| TC-UEM-03 | Chưa đăng nhập đọc `userEmails` | Đã đăng xuất | 1) Đọc `userEmails` | Bị từ chối quyền | Cao | Âm tính |
| TC-UEM-04 | Chưa đăng nhập ghi `userEmails` | Đã đăng xuất | 1) Ghi `userEmails/{key}` | Bị từ chối quyền | Cao | Âm tính |
| TC-UEM-05 | Trùng key email giữa 2 user | A và B đều đăng nhập hợp lệ | 1) A ghi key X 2) B ghi đè key X | Theo rule hiện tại vẫn cho phép (ghi nhận rủi ro nghiệp vụ) | Thấp | Biên |

---

## 3) Bảng `tasks`

| Mã TC | Tiêu đề | Điều kiện tiên quyết | Bước thực hiện | Kết quả mong đợi | Mức ưu tiên | Loại |
|---|---|---|---|---|---|---|
| TC-TSK-01 | Chủ sở hữu đọc/cập nhật task cá nhân | Task có `groupId=null`, `createdByUserId=A`, A đã đăng nhập | 1) A đọc task 2) A cập nhật task | Đọc/ghi thành công | Cao | Dương tính |
| TC-TSK-02 | User B đọc task cá nhân của A | Task cá nhân của A tồn tại, B đã đăng nhập | 1) B đọc task của A | Bị từ chối quyền | Cao | Âm tính |
| TC-TSK-03 | Thành viên nhóm đọc task nhóm | Task thuộc `groupId=G1`, có `userGroups/A/G1`, A đã đăng nhập | 1) A đọc task nhóm | Đọc thành công | Cao | Dương tính |
| TC-TSK-04 | Leader nhóm cập nhật task nhóm | `groups/G1/leaderUserId=A`, A đã đăng nhập | 1) A cập nhật title/description/dueDate/assignee/isDone | Ghi thành công | Cao | Dương tính |
| TC-TSK-05 | Người được giao chỉ được tick done từ false->true | Task có `assignedToUserId=A`, `isDone=false`, A đã đăng nhập | 1) A đổi `isDone=true` 2) Thử sửa thêm field khác | Chỉ cho phép đổi done đúng điều kiện; sửa field khác bị từ chối | Cao | Âm tính |

---

## 4) Bảng `groups`

| Mã TC | Tiêu đề | Điều kiện tiên quyết | Bước thực hiện | Kết quả mong đợi | Mức ưu tiên | Loại |
|---|---|---|---|---|---|---|
| TC-GRP-01 | Người dùng đã đăng nhập đọc danh sách nhóm | Đã đăng nhập | 1) Đọc `groups` | Đọc thành công | Trung bình | Dương tính |
| TC-GRP-02 | Người dùng đã đăng nhập tạo nhóm mới | Đã đăng nhập | 1) Tạo `groups/{newId}` | Ghi thành công | Trung bình | Dương tính |
| TC-GRP-03 | Người dùng cập nhật nhóm của người khác | A đã đăng nhập, nhóm của B tồn tại | 1) A cập nhật nhóm của B | Theo rule hiện tại vẫn cho phép (rủi ro phân quyền) | Thấp | Biên |
| TC-GRP-04 | Chưa đăng nhập đọc `groups` | Đã đăng xuất | 1) Đọc `groups` | Bị từ chối quyền | Cao | Âm tính |
| TC-GRP-05 | Chưa đăng nhập ghi `groups` | Đã đăng xuất | 1) Ghi `groups/{id}` | Bị từ chối quyền | Cao | Âm tính |

---

## 5) Bảng `userGroups`

| Mã TC | Tiêu đề | Điều kiện tiên quyết | Bước thực hiện | Kết quả mong đợi | Mức ưu tiên | Loại |
|---|---|---|---|---|---|---|
| TC-UGR-01 | Người dùng đã đăng nhập đọc membership map | Đã đăng nhập | 1) Đọc `userGroups` | Đọc thành công | Trung bình | Dương tính |
| TC-UGR-02 | Người dùng thêm membership cho user khác | A đã đăng nhập, B tồn tại | 1) A ghi `userGroups/B/G1=true` | Theo rule hiện tại vẫn cho phép (rủi ro phân quyền) | Thấp | Biên |
| TC-UGR-03 | Người dùng tự xóa membership của mình | A đã đăng nhập, có `userGroups/A/G1` | 1) A xóa `userGroups/A/G1` | Ghi thành công | Trung bình | Dương tính |
| TC-UGR-04 | Chưa đăng nhập đọc `userGroups` | Đã đăng xuất | 1) Đọc `userGroups` | Bị từ chối quyền | Cao | Âm tính |
| TC-UGR-05 | Chưa đăng nhập ghi `userGroups` | Đã đăng xuất | 1) Ghi `userGroups/{uid}/{gid}` | Bị từ chối quyền | Cao | Âm tính |

---

## 6) Bảng `login_history`

| Mã TC | Tiêu đề | Điều kiện tiên quyết | Bước thực hiện | Kết quả mong đợi | Mức ưu tiên | Loại |
|---|---|---|---|---|---|---|
| TC-LGH-01 | Người dùng đã đăng nhập ghi lịch sử đăng nhập | Đã đăng nhập | 1) Ghi `login_history/{id}` có `time` | Ghi thành công | Trung bình | Dương tính |
| TC-LGH-02 | Người dùng đã đăng nhập đọc lịch sử đăng nhập | Đã đăng nhập | 1) Đọc `login_history` | Đọc thành công | Trung bình | Dương tính |
| TC-LGH-03 | Chưa đăng nhập ghi lịch sử đăng nhập | Đã đăng xuất | 1) Ghi `login_history/{id}` | Bị từ chối quyền | Cao | Âm tính |
| TC-LGH-04 | Chưa đăng nhập đọc lịch sử đăng nhập | Đã đăng xuất | 1) Đọc `login_history` | Bị từ chối quyền | Cao | Âm tính |
| TC-LGH-05 | Truy vấn login history theo time (index) | Đã đăng nhập, dữ liệu có `time` | 1) Truy vấn theo `time` | Truy vấn chạy ổn, không lỗi index/rule | Thấp | Dương tính |
