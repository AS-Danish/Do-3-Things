import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

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

  int completedTasks = 0;
  int totalTasks = 3;

  // ============== LIFECYCLE ==============
  @override
  void initState() {
    super.initState();
    _initializeAnimation();
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
  void _completeTask() {
    if (completedTasks < totalTasks) {
      setState(() {
        completedTasks++;
      });
      final newProgress = completedTasks / totalTasks;
      _animateToProgress(newProgress);
    }
  }

  void _resetProgress() {
    setState(() {
      completedTasks = 0;
    });
    _animateToProgress(0.0);
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
        _buildGreeting(),
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
          'Sunday, Oct 12',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[500],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ============== PROGRESS SECTION ==============
  Widget _buildProgressSection() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildProgressCircle(),
          const SizedBox(height: 32),
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
            const SizedBox(height: 28),
            _buildProgressLabel(),
            const SizedBox(height: 8),
            _buildProgressMessage(),
            const SizedBox(height: 24),
            _buildActionButtons(),
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

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _completeTask,
          icon: const Icon(Icons.add_task),
          label: const Text('Complete Task'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _resetProgress,
          icon: const Icon(Icons.refresh),
          label: const Text('Reset'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[400],
            foregroundColor: Colors.white,
          ),
        ),
      ],
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