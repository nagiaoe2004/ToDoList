import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/application/app_controller.dart';
import 'package:todo_list/domain/models/group.dart';
import 'package:todo_list/features/groups/presentation/group_detail_screen.dart';
import 'package:todo_list/shared/presentation/helio_surface.dart';

/// Danh sách nhóm; tạo nhóm / mở chi tiết qua [AppController].
class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  Future<void> _createGroup(BuildContext context, AppController app) async {
    final TextEditingController name = TextEditingController();
    final TextEditingController workDescription = TextEditingController();
    final TextEditingController companyName = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Tạo nhóm làm việc'),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Tên nhóm',
                    hintText: 'VD: Team Marketing Miền Nam',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: workDescription,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Công việc chính',
                    hintText: 'VD: Triển khai chiến dịch Q3 và báo cáo tuần',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: companyName,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Tên công ty (tuỳ chọn)',
                    hintText: 'VD: ABC Holdings',
                  ),
                ),
              ],
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
                if (!context.mounted) return;
                if (err != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err)),
                  );
                  return;
                }
                Navigator.pop(context);
              },
              child: const Text('Tạo'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (BuildContext context, AppController app, _) {
        final List<Group> groups = app.myGroups;
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _createGroup(context, app),
            icon: const Icon(Icons.group_add_rounded),
            label: const Text('Nhóm mới'),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const HelioGradientHero(
                    title: 'Nhóm',
                    subtitle: 'Thêm thành viên, giao việc chung, tick trong nhóm',
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: groups.isEmpty
                        ? const Center(
                            child: Text(
                              'Chưa có nhóm. Tạo nhóm mới để bắt đầu.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: groups.length,
                            separatorBuilder: (BuildContext _, int __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (BuildContext context, int index) {
                              final Group g = groups[index];
                              return Material(
                                color: Theme.of(context).colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => GroupDetailScreen(
                                          groupId: g.id,
                                          groupName: g.name,
                                          groupWorkDescription:
                                              g.workDescription,
                                          groupCompanyName: g.companyName,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: Icon(
                                            Icons.groups_rounded,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                g.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                g.workDescription,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                              if (g.companyName != null &&
                                                  g.companyName!.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                      ),
                                                  child: Text(
                                                    g.companyName!,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${g.memberUserIds.length} thành viên',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              'Nhóm',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            const SizedBox(height: 6),
                                            const Icon(Icons.chevron_right_rounded),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
