import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/application/app_controller.dart';
import 'package:todo_list/domain/models/group.dart';
import 'package:todo_list/features/groups/presentation/group_detail_screen.dart';
import 'package:todo_list/shared/presentation/helio_surface.dart';

/// Danh sách nhóm: tìm kiếm, lọc, sắp xếp, làm mới kéo xuống.
class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final TextEditingController _search = TextEditingController();

  /// `name` | `members`
  String _sortBy = 'name';

  /// Chỉ nhóm đã nhập tên dự án
  bool _onlyWithCompany = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Group> _filteredAndSorted(List<Group> all) {
    final String q = _search.text.trim().toLowerCase();
    List<Group> list = all.where((Group g) {
      if (_onlyWithCompany &&
          (g.companyName == null || g.companyName!.trim().isEmpty)) {
        return false;
      }
      if (q.isEmpty) {
        return true;
      }
      return g.name.toLowerCase().contains(q) ||
          g.workDescription.toLowerCase().contains(q) ||
          (g.companyName?.toLowerCase().contains(q) ?? false);
    }).toList();

    if (_sortBy == 'members') {
      list.sort(
        (Group a, Group b) =>
            b.memberUserIds.length.compareTo(a.memberUserIds.length),
      );
    } else {
      list.sort(
        (Group a, Group b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    }
    return list;
  }

  int _totalMembersAcross(List<Group> groups) {
    int n = 0;
    for (final Group g in groups) {
      n += g.memberUserIds.length;
    }
    return n;
  }

  Future<void> _createGroup(BuildContext context, AppController app) async {
    final TextEditingController name = TextEditingController();
    final TextEditingController workDescription = TextEditingController();
    final TextEditingController companyName = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: <Widget>[
              Icon(
                Icons.groups_2_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Tạo nhóm làm việc',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    controller: name,
                    textCapitalization: TextCapitalization.words,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Tên nhóm',
                      hintText: 'VD: Team Marketing Miền Nam',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: workDescription,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Công việc chính',
                      hintText: 'Mục tiêu ngắn gọn của nhóm',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.task_alt_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: companyName,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Tên dự án (tuỳ chọn)',
                      hintText: 'VD: ABC Holdings',
                      prefixIcon: Icon(Icons.apartment_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ'),
            ),
            FilledButton(
              onPressed: () async {
                final String? err = await app.createGroup(
                  name: name.text,
                  workDescription: workDescription.text,
                  companyName: companyName.text,
                );
                if (!context.mounted) {
                  return;
                }
                if (err != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err)),
                  );
                  return;
                }
                Navigator.pop(context);
              },
              child: const Text('Tạo nhóm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Consumer<AppController>(
      builder: (BuildContext context, AppController app, _) {
        final List<Group> groups = app.myGroups;
        final List<Group> visible = _filteredAndSorted(groups);
        final int totalMembers = _totalMembersAcross(groups);

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _createGroup(context, app),
            icon: const Icon(Icons.group_add_rounded),
            label: const Text('Nhóm mới'),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const HelioGradientHero(
                    title: 'Nhóm làm việc',
                    subtitle:
                        'Phối hợp nhóm, giao việc chung và theo dõi tiến độ',
                  ),
                  const SizedBox(height: 12),
                  if (groups.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _StatChip(
                          icon: Icons.folder_shared_outlined,
                          label: '${groups.length} nhóm',
                          scheme: scheme,
                        ),
                        _StatChip(
                          icon: Icons.people_outline_rounded,
                          label: '$totalMembers lượt thành viên',
                          scheme: scheme,
                        ),
                      ],
                    ),
                  if (groups.isNotEmpty) const SizedBox(height: 12),
                  TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tên nhóm, công việc, dự án…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _search.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _search.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        FilterChip(
                          label: const Text('Có tên dự án'),
                          selected: _onlyWithCompany,
                          onSelected: (bool v) =>
                              setState(() => _onlyWithCompany = v),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Sắp theo tên'),
                          selected: _sortBy == 'name',
                          onSelected: (_) =>
                              setState(() => _sortBy = 'name'),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Nhiều thành viên'),
                          selected: _sortBy == 'members',
                          onSelected: (_) =>
                              setState(() => _sortBy = 'members'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: groups.isEmpty
                        ? _EmptyGroups(onCreate: () => _createGroup(context, app))
                        : RefreshIndicator(
                            onRefresh: () => app.refreshGroups(),
                            child: visible.isEmpty
                                ? ListView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    children: <Widget>[
                                      const SizedBox(height: 48),
                                      Center(
                                        child: Text(
                                          'Không có nhóm khớp bộ lọc.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: scheme.onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                    ],
                                  )
                                : ListView.separated(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.only(bottom: 88),
                                    itemCount: visible.length,
                                    separatorBuilder:
                                        (BuildContext _, int __) =>
                                            const SizedBox(height: 10),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final Group g = visible[index];
                                      return Material(
                                        elevation: 0,
                                        color: scheme.surfaceContainerLow,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute<void>(
                                                builder: (_) =>
                                                    GroupDetailScreen(
                                                  groupId: g.id,
                                                  groupName: g.name,
                                                  groupWorkDescription:
                                                      g.workDescription,
                                                  groupCompanyName:
                                                      g.companyName,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 14,
                                            ),
                                            child: Row(
                                              children: <Widget>[
                                                Container(
                                                  width: 52,
                                                  height: 52,
                                                  decoration: BoxDecoration(
                                                    color: scheme
                                                        .primaryContainer
                                                        .withValues(
                                                      alpha: 0.45,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      14,
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.groups_rounded,
                                                    color: scheme.primary,
                                                    size: 28,
                                                  ),
                                                ),
                                                const SizedBox(width: 14),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        g.name,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        g.workDescription,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall,
                                                      ),
                                                      if (g.companyName !=
                                                              null &&
                                                          g.companyName!
                                                              .isNotEmpty)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            top: 6,
                                                          ),
                                                          child: Row(
                                                            children: <Widget>[
                                                              Icon(
                                                                Icons
                                                                    .business_rounded,
                                                                size: 14,
                                                                color: scheme
                                                                    .primary,
                                                              ),
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  g.companyName!,
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodySmall
                                                                      ?.copyWith(
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: <Widget>[
                                                    Container(
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: scheme.primary
                                                            .withValues(
                                                          alpha: 0.12,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          20,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons
                                                                .people_alt_outlined,
                                                            size: 16,
                                                            color: scheme
                                                                .primary,
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text(
                                                            '${g.memberUserIds.length}',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: scheme
                                                                  .primary,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Icon(
                                                      Icons
                                                          .chevron_right_rounded,
                                                      color: scheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.scheme,
  });

  final IconData icon;
  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _EmptyGroups extends StatelessWidget {
  const _EmptyGroups({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.groups_2_outlined,
              size: 72,
              color: scheme.primary.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có nhóm',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tạo nhóm để giao việc chung và cùng theo dõi tiến độ với team.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tạo nhóm đầu tiên'),
            ),
          ],
        ),
      ),
    );
  }
}
