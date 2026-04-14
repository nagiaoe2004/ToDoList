import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

/// Chuyển lỗi từ tầng data (mock/API) sang thông báo tiếng Việt cho người dùng.
/// UI chỉ hiển thị chuỗi trả về, không tự phân tích exception.
String mapRepositoryErrorToMessage(Object error) {
  if (error is TimeoutException) {
    return 'Kết nối mạng chậm hoặc máy chủ phản hồi lâu.';
  }
  if (error is FirebaseException) {
    if (error.code == 'permission-denied') {
      return 'Bạn chưa có quyền truy cập dữ liệu Firebase.';
    }
    if (error.code == 'unavailable') {
      return 'Firebase tạm thời không khả dụng. Vui lòng thử lại.';
    }
    return 'Lỗi Firebase: ${error.code}.';
  }
  if (error is ArgumentError) {
    return 'Dữ liệu không hợp lệ.';
  }
  if (error is StateError) {
    switch (error.message) {
      case 'Group not found':
        return 'Không tìm thấy nhóm.';
      case 'Not a member':
        return 'Bạn không phải thành viên nhóm này.';
      case 'User not found for email':
        return 'Không tìm thấy người dùng với email đó.';
      case 'Already in group':
        return 'Không thể thêm chính bạn (đã trong nhóm).';
      case 'Not a group member':
        return 'Bạn không thuộc nhóm này.';
      case 'User not found':
        return 'Không tìm thấy người dùng.';
      default:
        return 'Đã có lỗi xảy ra. Thử lại sau.';
    }
  }
  return 'Đã có lỗi xảy ra. Thử lại sau.';
}
