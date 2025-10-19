import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskService {
  final tasksBox = Hive.box<Task>('tasksBox');
  final String userId;

  TaskService(this.userId);

  // 🟢 Load from Hive (local cache)
  List<Task> loadLocalTasks() {
    return tasksBox.values.toList();
  }

  // 🟢 Save tasks to Hive
  Future<void> saveTasksToHive(List<Task> tasks) async {
    await tasksBox.clear(); // Replace all existing data
    for (var task in tasks) {
      await tasksBox.put(task.id, task);
    }
  }
}
