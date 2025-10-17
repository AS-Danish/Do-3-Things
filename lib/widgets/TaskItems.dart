import 'package:flutter/material.dart';
import '../models/Task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onOptionsPressed;

  const TaskItem({
    super.key,
    required this.task,
    required this.onTap,
    required this.onOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: _buildCheckbox(task.isCompleted),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: task.isCompleted ? Colors.grey[400] : Colors.grey[800],
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: task.isCompleted ? Colors.grey[350] : Colors.grey[600],
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onOptionsPressed,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(bool isCompleted) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? Colors.blue[600] : Colors.transparent,
        border: Border.all(
          color: isCompleted ? Colors.blue[600]! : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: isCompleted
          ? const Icon(
        Icons.check,
        size: 18,
        color: Colors.white,
      )
          : null,
    );
  }
}