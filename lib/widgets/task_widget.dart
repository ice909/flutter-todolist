import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskWidget extends StatelessWidget {
  final Task todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskWidget({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      clipBehavior: Clip.antiAlias, // 确保波纹效果不超出 Card 边界
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => (),
          child: Row(
            
            children: [
              Checkbox(
                value: todo.completed,
                onChanged: (_) => onToggle(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  todo.title,
                  style: TextStyle(
                    decoration: todo.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: todo.completed ? Colors.grey : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
