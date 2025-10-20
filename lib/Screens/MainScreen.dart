import 'package:flutter/material.dart';
import '../widgets/AddTaskModal.dart';
import '../widgets/CustomBottomNav.dart';
import '../services/TaskService.dart';
import 'HomeScreen.dart';
import 'ProfileScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Default userId until login system is implemented
  static const String defaultUserId = 'default_user';

  late final TaskService _taskService;
  late final List<Widget> _screens;
  final GlobalKey<HomeScreenState> _homeScreenKey = GlobalKey<HomeScreenState>();

  @override
  void initState() {
    super.initState();
    _taskService = TaskService(defaultUserId);
    _screens = [
      HomeScreen(
        key: _homeScreenKey,
        userId: defaultUserId,
      ), // Index 0
      const ProfileScreen(), // Index 1
    ];
  }

  void _onNavigationTap(int index) {
    // If middle button (index 1 from CustomBottomNav) is tapped, show modal
    if (index == 1) {
      _showAddTaskModal();
    }
    // If Home button (index 0) is tapped
    else if (index == 0) {
      setState(() {
        _currentIndex = 0;
      });
    }
    // If Profile button (index 2 from CustomBottomNav) is tapped
    else if (index == 2) {
      setState(() {
        _currentIndex = 1; // Map to index 1 in _screens
      });
    }
  }

  void _showAddTaskModal() {
    // Get the selected date from HomeScreen
    final DateTime selectedDate = _homeScreenKey.currentState?.selectedDate ?? DateTime.now();

    // Check if the selected date has 3 tasks with any incomplete
    if (AddTaskModal.hasDateThreeIncompleteTasks(_taskService, selectedDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Complete all ${selectedDate.day}/${selectedDate.month} tasks to add more',
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
      return; // Don't show the modal
    }

    // If less than 3 tasks or all completed, show the modal with selected date
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add Task',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AddTaskModal(taskService: _taskService);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(curvedAnimation),
              child: child,
            ),
          ),
        );
      },
    ).then((newTask) {
      // Refresh the HomeScreen when a task is added
      if (newTask != null && _homeScreenKey.currentState != null) {
        _homeScreenKey.currentState!.refreshTasks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex == 0 ? 0 : (_currentIndex == 1 ? 2 : 0),
        onTap: _onNavigationTap,
      ),
    );
  }
}