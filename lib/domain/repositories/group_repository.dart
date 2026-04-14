import 'package:todo_list/domain/models/app_user.dart';
import 'package:todo_list/domain/models/group.dart';

/// Nhóm: danh sách, tạo, thêm thành viên, xem thành viên.
abstract class GroupRepository {
  Future<List<Group>> listGroupsForUser(String userId);

  Future<Group> createGroup({
    required String userId,
    required String name,
    required String workDescription,
    String? companyName,
  });

  Future<void> addMemberByEmail({
    required String groupId,
    required String actorUserId,
    required String memberEmail,
  });

  Future<List<AppUser>> listMembers(String groupId);
}
