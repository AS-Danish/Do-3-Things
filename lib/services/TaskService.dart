import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskService {
  final tasksBox = Hive.box<Task>('tasksBox');
  final String userId;

  TaskService(this.userId);

  // 🟢 Load all tasks from Hive (local cache)
  List<Task> loadLocalTasks() {
    return tasksBox.values.toList();
  }

  // 🟢 Load tasks filtered by date
  List<Task> loadTasksByDate(DateTime date) {
    final allTasks = tasksBox.values.toList();
    return allTasks.where((task) {
      if (task.dueDate == null) return false;
      return _isSameDate(task.dueDate!, date);
    }).toList();
  }

  // 🟢 Load tasks filtered by date range
  List<Task> loadTasksByDateRange(DateTime startDate, DateTime endDate) {
    final allTasks = tasksBox.values.toList();
    return allTasks.where((task) {
      if (task.dueDate == null) return false;
      final taskDate = _normalizeDate(task.dueDate!);
      final start = _normalizeDate(startDate);
      final end = _normalizeDate(endDate);
      return (taskDate.isAfter(start) || taskDate.isAtSameMomentAs(start)) &&
          (taskDate.isBefore(end) || taskDate.isAtSameMomentAs(end));
    }).toList();
  }

  // 🟢 Load completed tasks
  List<Task> loadCompletedTasks() {
    final allTasks = tasksBox.values.toList();
    return allTasks.where((task) => task.isCompleted).toList();
  }

  // 🟢 Load pending tasks
  List<Task> loadPendingTasks() {
    final allTasks = tasksBox.values.toList();
    return allTasks.where((task) => !task.isCompleted).toList();
  }

  // 🟢 Load overdue tasks
  List<Task> loadOverdueTasks() {
    final now = DateTime.now();
    final today = _normalizeDate(now);
    final allTasks = tasksBox.values.toList();

    return allTasks.where((task) {
      if (task.dueDate == null) return false;
      final taskDate = _normalizeDate(task.dueDate!);
      return !task.isCompleted && taskDate.isBefore(today);
    }).toList();
  }

  // 🟢 Load today's tasks
  List<Task> loadTodaysTasks() {
    return loadTasksByDate(DateTime.now());
  }

  // 🟢 Load tasks for current week
  List<Task> loadWeekTasks() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return loadTasksByDateRange(startOfWeek, endOfWeek);
  }

  // 🟢 Load tasks for current month
  List<Task> loadMonthTasks() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return loadTasksByDateRange(startOfMonth, endOfMonth);
  }

  // 🟢 Save tasks to Hive
  Future<void> saveTasksToHive(List<Task> tasks) async {
    await tasksBox.clear(); // Replace all existing data
    for (var task in tasks) {
      await tasksBox.put(task.id, task);
    }
  }

  // 🟢 Add or update a single task
  Future<void> saveTask(Task task) async {
    await tasksBox.put(task.id, task);
  }

  // 🟢 Delete a single task
  Future<void> deleteTask(String taskId) async {
    await tasksBox.delete(taskId);
  }

  // 🟢 Get task count by date
  int getTaskCountByDate(DateTime date) {
    return loadTasksByDate(date).length;
  }

  // 🟢 Get completed task count by date
  int getCompletedTaskCountByDate(DateTime date) {
    final tasks = loadTasksByDate(date);
    return tasks.where((task) => task.isCompleted).length;
  }

  // 🟢 Get progress for a specific date (0.0 to 1.0)
  double getProgressByDate(DateTime date) {
    final tasks = loadTasksByDate(date);
    if (tasks.isEmpty) return 0.0;
    final completed = tasks.where((task) => task.isCompleted).length;
    return completed / tasks.length;
  }

  // ============== HELPER METHODS ==============

  // Check if two dates are the same (ignoring time)
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Normalize date to midnight (remove time component)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}