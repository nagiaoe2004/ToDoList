import 'package:flutter/material.dart';
import 'package:todo_list/domain/models/task_item.dart';
import 'package:todo_list/utils/date_format.dart';

/// Một dòng công việc: checkbox, nội dung, xóa (chỉ UI).
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onDelete,
    this.metaText,
    this.canToggle = true,
    this.canDelete = true,
  });

  final TaskItem item;
  final ValueChanged<bool> onChanged;
  final VoidCallback onDelete;
  final String? metaText;
  final bool canToggle;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Checkbox(
              value: item.isDone,
              onChanged: canToggle
                  ? (bool? value) => onChanged(value ?? false)
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: scheme.onSurface,
                      decoration: item.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.description.isEmpty ? 'Chưa có mô tả' : item.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hạn: ${formatDate(item.dueDate)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (metaText != null && metaText!.trim().isNotEmpty) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      metaText!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 8, right: 4),
              decoration: BoxDecoration(
                color: item.isDone
                    ? const Color(0xFF2ECC71)
                    : const Color(0xFFFF9F43),
                shape: BoxShape.circle,
              ),
            ),
            IconButton(
              onPressed: canDelete ? onDelete : null,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
