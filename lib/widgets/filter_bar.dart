import 'package:flutter/material.dart';
import 'package:todo_list/domain/models/task_filter.dart';

/// Ô tìm + bộ lọc dạng segmented.
class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.controller,
    required this.selected,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  final TextEditingController controller;
  final TaskFilter selected;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<TaskFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: controller,
          onChanged: onSearchChanged,
          decoration: const InputDecoration(
            hintText: 'Tìm công việc',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFDDE2EE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
          children: <Widget>[
            Expanded(
              child: _FilterPill(
                title: 'Tất cả',
                selected: selected == TaskFilter.all,
                onTap: () => onFilterChanged(TaskFilter.all),
              ),
            ),
            Expanded(
              child: _FilterPill(
                title: 'Chưa xong',
                selected: selected == TaskFilter.pending,
                onTap: () => onFilterChanged(TaskFilter.pending),
              ),
            ),
            Expanded(
              child: _FilterPill(
                title: 'Hoàn thành',
                selected: selected == TaskFilter.completed,
                onTap: () => onFilterChanged(TaskFilter.completed),
              ),
            ),
          ],
        ),
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF5B67FF)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF15171A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
