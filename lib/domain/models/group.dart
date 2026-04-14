/// Nhóm làm việc chung; [memberUserIds] là id người dùng.
class Group {
  const Group({
    required this.id,
    required this.name,
    required this.memberUserIds,
    required this.workDescription,
    this.companyName,
  });

  final String id;
  final String name;
  final List<String> memberUserIds;
  final String workDescription;
  final String? companyName;

  Group copyWith({
    String? id,
    String? name,
    List<String>? memberUserIds,
    String? workDescription,
    String? companyName,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      memberUserIds: memberUserIds ?? this.memberUserIds,
      workDescription: workDescription ?? this.workDescription,
      companyName: companyName ?? this.companyName,
    );
  }
}
