import 'package:flutter/material.dart';
import '../models/task.dart';
import 'TaskItems.dart';

class TasksList extends StatelessWidget {
  final List<Task> tasks;
  final Function(String) onTaskTap;
  final Function(String) onTaskOptionsPressed;

  const TasksList({
    super.key,
    required this.tasks,
    required this.onTaskTap,
    required this.onTaskOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Today\'s Tasks',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Colors.grey[800],
            ),
          ),
        ),
        ...tasks
            .map((task) => TaskItem(
          task: task,
          onTap: () => onTaskTap(task.id),
          onOptionsPressed: () => onTaskOptionsPressed(task.id),
        ))
            .toList(),
      ],
    );
  }
}