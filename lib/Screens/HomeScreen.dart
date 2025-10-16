import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import '../widgets/TaskOptionsPopUp.dart';

/// Task Model
class Task {
  final String id;
  String title;
  String description;
  DateTime? dueDate;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.isCompleted = false,
  });
}

/// Main Home Screen Widget
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ============== CONSTANTS ==============
  static const double paddingHorizontal = 16.0;
  static const double avatarSize = 56.0;
  static const double spacingSmall = 4.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 10.0;
  static const double progressIndicatorSize = 220.0;
  static const double progressStrokeWidth = 10.0;

  // ============== STATE VARIABLES ==============
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  DateTime selectedDate = DateTime.now();

  List<Task> tasks = [];

  int get completedTasks => tasks.where((task) => task.isCompleted).length;
  int get totalTasks => tasks.length;

  // ============== LIFECYCLE ==============
  @override
  void initState() {
    super.initState();
    _initializeSampleTasks();
    _initializeAnimation();
  }

  void _initializeSampleTasks() {
    tasks = [
      Task(
        id: '1',
        title: 'Complete project documentation',
        description: 'Write comprehensive documentation for the new feature',
        dueDate: DateTime.now().add(const Duration(days: 2)),
      ),
      Task(
        id: '2',
        title: 'Review pull requests',
        description: 'Review and approve pending PRs from team members',
        dueDate: DateTime.now().add(const Duration(days: 1)),
      ),
      Task(
        id: '3',
        title: 'Update design mockups',
        description: 'Finalize UI designs based on client feedback',
        dueDate: DateTime.now().add(const Duration(days: 3)),
      ),
    ];
  }

  void _initializeAnimation() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _updateProgressAnimation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _progressController.forward();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  // ============== ANIMATION METHODS ==============
  void _updateProgressAnimation() {
    final progressValue = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    _progressAnimation = Tween<double>(begin: 0.0, end: progressValue).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOutCubic),
    );
  }

  void _animateToProgress(double targetProgress) {
    final currentProgress = _progressAnimation.value;
    _progressAnimation = Tween<double>(begin: currentProgress, end: targetProgress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOutCubic),
    );
    _progressController.forward(from: 0.0);
  }

  // ============== TASK METHODS ==============
  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[600]!,
              onPrimary: Colors.white,
              onSurface: Colors.grey[800]!,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _toggleTask(String taskId) {
    setState(() {
      final task = tasks.firstWhere((t) => t.id == taskId);
      task.isCompleted = !task.isCompleted;
    });
    final newProgress = completedTasks / totalTasks;
    _animateToProgress(newProgress);
  }

  void _deleteTask(String taskId) {
    setState(() {
      tasks.removeWhere((task) => task.id == taskId);
    });
    final newProgress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    _animateToProgress(newProgress);
  }

  void _editTask(String taskId) {
    final task = tasks.firstWhere((t) => t.id == taskId);
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    DateTime? selectedDueDate = task.dueDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Colors.blue[600]!,
                              onPrimary: Colors.white,
                              onSurface: Colors.grey[800]!,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDueDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 12),
                        Text(
                          selectedDueDate != null
                              ? _formatDate(selectedDueDate!)
                              : 'Select Due Date',
                          style: TextStyle(
                            fontSize: 16,
                            color: selectedDueDate != null ? Colors.grey[800] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  setState(() {
                    task.title = titleController.text.trim();
                    task.description = descriptionController.text.trim();
                    task.dueDate = selectedDueDate;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskOptions(Task task) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => TaskOptionsPopup(
        onEdit: () {
          Navigator.pop(context);
          _editTask(task.id);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteTask(task.id);
        },
      ),
    );
  }

  void _addNewTask() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDueDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Colors.blue[600]!,
                              onPrimary: Colors.white,
                              onSurface: Colors.grey[800]!,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDueDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 12),
                        Text(
                          selectedDueDate != null
                              ? _formatDate(selectedDueDate!)
                              : 'Select Due Date',
                          style: TextStyle(
                            fontSize: 16,
                            color: selectedDueDate != null ? Colors.grey[800] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  setState(() {
                    tasks.add(Task(
                      id: DateTime.now().toString(),
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      dueDate: selectedDueDate,
                    ));
                  });
                  _updateProgressAnimation();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ============== UI BUILD ==============
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(paddingHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: spacingLarge),
                _buildProgressSection(),
                tasks.isEmpty ? _buildEmptyState() : _buildTasksList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============== HEADER SECTION ==============
  Widget _buildHeader() {
    return Row(
      children: [
        _buildAvatar(),
        const SizedBox(width: spacingMedium),
        Expanded(child: _buildGreeting()),
        _buildCalendarButton(),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue[100],
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/avatar.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                'D',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    final dayName = days[selectedDate.weekday - 1];
    final monthName = months[selectedDate.month - 1];
    final dayNumber = selectedDate.day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good Morning, Danish',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: spacingSmall),
        Text(
          '$dayName, $monthName $dayNumber',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[500],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue[100]!,
          width: 1.5,
        ),
      ),
      child: IconButton(
        icon: Icon(
          Icons.calendar_today,
          color: Colors.blue[600],
          size: 20,
        ),
        onPressed: _selectDate,
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(),
        tooltip: 'Select Date',
      ),
    );
  }

  // ============== PROGRESS SECTION ==============
  Widget _buildProgressSection() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: tasks.isEmpty ? 20 : 40),
          _buildProgressCircle(),
          SizedBox(height: tasks.isEmpty ? 16 : 32),
        ],
      ),
    );
  }

  Widget _buildProgressCircle() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Column(
          children: [
            _buildCircleWithGlow(),
            if (tasks.isNotEmpty) ...[
              const SizedBox(height: 28),
              _buildProgressLabel(),
              const SizedBox(height: 8),
              _buildProgressMessage(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCircleWithGlow() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow
        Container(
          width: progressIndicatorSize + 20,
          height: progressIndicatorSize + 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.blue.withOpacity(0.1),
                Colors.blue.withOpacity(0.0),
              ],
            ),
          ),
        ),
        // Progress circle
        SizedBox(
          width: progressIndicatorSize,
          height: progressIndicatorSize,
          child: CustomPaint(
            painter: CircularProgressPainter(
              progress: _progressAnimation.value,
              strokeWidth: progressStrokeWidth,
            ),
          ),
        ),
        // Center content
        _buildCenterContent(),
      ],
    );
  }

  Widget _buildCenterContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${(_progressAnimation.value * 100).toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: Colors.blue[700],
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.blue[100]!,
              width: 1.5,
            ),
          ),
          child: Text(
            '$completedTasks/$totalTasks tasks',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLabel() {
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }
    return Text(
      'Today\'s Progress',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.grey[800],
        fontSize: 16,
      ),
    );
  }

  Widget _buildProgressMessage() {
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }

    final message = completedTasks == totalTasks
        ? '🎉 All tasks completed!'
        : 'Keep going! Complete ${totalTasks - completedTasks} more task${totalTasks - completedTasks > 1 ? 's' : ''}';

    return Text(
      message,
      style: TextStyle(
        fontSize: 13,
        color: Colors.grey[500],
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ============== EMPTY STATE ==============
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            '✨',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'Start your day by adding tasks',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Make today count',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 32),
          _buildQuickTips(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildQuickTips() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Text(
            'Quick Tips',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildTipItem('📝', 'Break down big goals into smaller tasks'),
          const SizedBox(height: 12),
          _buildTipItem('⏰', 'Set realistic deadlines for yourself'),
          const SizedBox(height: 12),
          _buildTipItem('🎯', 'Focus on your most important task first'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String emoji, String text) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // ============== TASKS LIST SECTION ==============
  Widget _buildTasksList() {
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
        ...tasks.map((task) => _buildTaskItem(task)).toList(),
      ],
    );
  }

  Widget _buildTaskItem(Task task) {
    return Container(
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
              child: GestureDetector(
                onTap: () => _toggleTask(task.id),
                child: _buildCheckbox(task.isCompleted),
              ),
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
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.grey[600]),
              onPressed: () => _showTaskOptions(task),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  bool _isOverdue(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return dueDateOnly.isBefore(today);
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
          ? Icon(
        Icons.check,
        size: 18,
        color: Colors.white,
      )
          : null,
    );
  }
}

/// Custom painter for circular progress indicator
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth * 2);

    _drawBackgroundCircle(canvas, center, radius);
    _drawProgressArc(canvas, center, radius, size);
    _drawProgressDot(canvas, center, radius);
  }

  void _drawBackgroundCircle(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, paint);
  }

  void _drawProgressArc(Canvas canvas, Offset center, double radius, Size size) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..shader = ui.Gradient.linear(
        Offset(size.width / 2 - radius, size.height / 2 - radius),
        Offset(size.width / 2 + radius, size.height / 2 + radius),
        [Colors.blue[400]!, Colors.blue[600]!],
      );

    final sweepAngle = progress * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  void _drawProgressDot(Canvas canvas, Offset center, double radius) {
    if (progress <= 0.01) return;

    final dotAngle = (progress * 2 * math.pi) - (math.pi / 2);
    final dotX = center.dx + radius * math.cos(dotAngle);
    final dotY = center.dy + radius * math.sin(dotAngle);
    final dotPos = Offset(dotX, dotY);

    // Glow
    canvas.drawCircle(
      dotPos,
      strokeWidth * 1.5,
      Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // White border
    canvas.drawCircle(
      dotPos,
      strokeWidth * 0.9,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    // Blue fill
    canvas.drawCircle(
      dotPos,
      strokeWidth * 0.7,
      Paint()
        ..color = Colors.blue[600]!
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}