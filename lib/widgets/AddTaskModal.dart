import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/TaskService.dart';

class AddTaskModal extends StatefulWidget {
  final TaskService taskService;
  final DateTime? initialDate;

  const AddTaskModal({
    super.key,
    required this.taskService,
    this.initialDate,
  });

  // Static method to check if a specific date has any incomplete tasks when limit was reached
  static bool hasDateThreeIncompleteTasks(TaskService taskService, DateTime date) {
    final allTasks = taskService.tasksBox.values.toList();
    final dateOnly = DateTime(date.year, date.month, date.day);

    // Get all tasks for today (both completed and incomplete)
    final todayTasks = allTasks.where((task) {
      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      return taskDate == dateOnly;
    }).toList();

    // If there are 3 or more tasks total for today
    if (todayTasks.length >= 3) {
      // Check if any are incomplete
      final hasIncomplete = todayTasks.any((task) => !task.isCompleted);
      return hasIncomplete; // Block if any task is incomplete
    }

    return false; // Allow if less than 3 tasks total
  }

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal>
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _selectedDate;
  late AnimationController _contentAnimationController;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    // Use initialDate if provided, otherwise use today
    _selectedDate = widget.initialDate ?? DateTime.now();
    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentAnimation = CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutCubic,
    );
    _contentAnimationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  // Check if the selected date has 3 tasks and any are incomplete
  bool _hasThreeIncompleteTasks() {
    final allTasks = widget.taskService.tasksBox.values.toList();

    final selectedDateOnly = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    // Get all tasks for the selected date
    final dateTasks = allTasks.where((task) {
      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      return taskDate == selectedDateOnly;
    }).toList();

    // If there are 3 or more tasks for this date
    if (dateTasks.length >= 3) {
      // Check if any are incomplete
      return dateTasks.any((task) => !task.isCompleted);
    }

    return false;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.grey.shade800,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a task title'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Check if there are already 3 tasks with any incomplete for the SELECTED date
    if (_hasThreeIncompleteTasks()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Complete all ${_selectedDate.day}/${_selectedDate.month} tasks to add more',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Create new task
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _selectedDate,
      isCompleted: false,
    );

    // Save to Hive
    await widget.taskService.tasksBox.put(newTask.id, newTask);

    if (!mounted) return;

    Navigator.pop(context, newTask); // Return the new task

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            const Text('Task added successfully!'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasLimit = _hasThreeIncompleteTasks();

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: FadeTransition(
              opacity: _contentAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade600, Colors.blue.shade800],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade300.withOpacity(0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_task_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Task',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[900],
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Stay organized and productive',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded, color: Colors.grey[400]),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Warning banner if limit reached
                  if (hasLimit)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'This date has 3 incomplete tasks. Complete them first!',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Task Title
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Task Title',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _titleController,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[900],
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter task title',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: Icon(Icons.edit_outlined,
                              color: Colors.grey[400], size: 20),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: Colors.blue.shade600, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description (Optional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[900],
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add more details...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w400,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: Colors.blue.shade600, width: 2),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Date Selector
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  color: Colors.blue.shade700, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[900],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            backgroundColor: Colors.grey[100],
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _saveTask,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.blue.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Create Task',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}