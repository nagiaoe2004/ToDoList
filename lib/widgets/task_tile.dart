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
  });

  final TaskItem item;
  final ValueChanged<bool> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Checkbox(
              value: item.isDone,
              onChanged: (bool? value) => onChanged(value ?? false),
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
                      color: const Color(0xFF15171A),
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
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
