// lib/features/tasks/presentation/screens/create_task_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme.dart';
import '../../../../common/widgets/animated_button.dart';
import '../../../../common/widgets/futuristic_text_field.dart';
import '../../../../data/models/task_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../workspaces/providers/workspace_provider.dart';
import '../../providers/task_provider.dart';

class CreateTaskScreen extends StatefulWidget {
  final String? workspaceId;

  const CreateTaskScreen({
    Key? key,
    this.workspaceId,
  }) : super(key: key);

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _dueDate;
  TimeOfDay? _dueTime;

  TaskPriority _priority = TaskPriority.medium;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final workspaceProvider =
          Provider.of<WorkspaceProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      final workspaceId =
          widget.workspaceId ?? workspaceProvider.currentWorkspace?.id;
      final currentUser = authProvider.user;

      if (workspaceId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workspace ID is missing'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to be signed in to create a task'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Combine date and time if set
      DateTime? combinedDateTime;
      if (_dueDate != null) {
        final date = _dueDate!;
        if (_dueTime != null) {
          combinedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            _dueTime!.hour,
            _dueTime!.minute,
          );
        } else {
          combinedDateTime = date;
        }
      }

      final success = await taskProvider.createTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        workspaceId: workspaceId,
        createdBy: currentUser.id,
        assignedTo: currentUser.id, // Currently assigning to self
        dueDate: combinedDateTime,
        priority: _priority,
      );

      if (success && mounted) {
        // Show success animation
        _showSuccessAnimation();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(taskProvider.errorMessage ?? 'Failed to create task'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isCreating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  void _showSuccessAnimation() {
    // Show a success animation and then navigate back
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 80,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Task Created!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your new task "${_titleController.text}" has been created successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Delay navigation to show the animation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        Navigator.of(context).pop(); // Go back to previous screen
      }
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });

      // Pick time after date is selected
      _pickTime();
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  String? _formatDateTime() {
    if (_dueDate == null) return null;

    final date = DateFormat('MMM d, yyyy').format(_dueDate!);
    final time = _dueTime != null ? _dueTime!.format(context) : null;

    return time != null ? '$date at $time' : date;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
        centerTitle: true,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task illustration
                      Center(
                        child: _TaskIllustration(),
                      ),
                      const SizedBox(height: 32),

                      // Form title
                      const Text(
                        'Create a New Task',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a task to your workspace and assign it to yourself or others.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Task title
                      FuturisticTextField(
                        label: 'Task Title',
                        hintText: 'e.g. Design landing page, Fix bug in login',
                        controller: _titleController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a task title';
                          }
                          if (value.trim().length < 3) {
                            return 'Title should be at least 3 characters';
                          }
                          return null;
                        },
                        prefixIcon: Icons.task_alt,
                      ),
                      const SizedBox(height: 24),

                      // Task description
                      FuturisticTextField(
                        label: 'Description (Optional)',
                        hintText: 'Add details about the task',
                        controller: _descriptionController,
                        prefixIcon: Icons.description,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 24),

                      // Due date
                      const Text(
                        'Due Date (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  _formatDateTime() ?? 'Select Due Date',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _dueDate != null
                                        ? Colors.black87
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              if (_dueDate != null)
                                IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey.shade600,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _dueDate = null;
                                      _dueTime = null;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Priority
                      const Text(
                        'Priority',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildPriorityOption(
                            label: 'Low',
                            priority: TaskPriority.low,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 12),
                          _buildPriorityOption(
                            label: 'Medium',
                            priority: TaskPriority.medium,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 12),
                          _buildPriorityOption(
                            label: 'High',
                            priority: TaskPriority.high,
                            color: Colors.red.shade700,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Create button
                      AnimatedButton(
                        text: 'Create Task',
                        onPressed: _createTask,
                        isLoading: _isCreating,
                        isFullWidth: true,
                        icon: Icons.add_task,
                        height: 56,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityOption({
    required String label,
    required TaskPriority priority,
    required Color color,
  }) {
    final isSelected = _priority == priority;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _priority = priority;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.flag,
                color: isSelected ? color : Colors.grey.shade600,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskIllustration extends StatefulWidget {
  @override
  State<_TaskIllustration> createState() => _TaskIllustrationState();
}

class _TaskIllustrationState extends State<_TaskIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),

          // Task circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),

          // Checkmark
          AnimatedBuilder(
            animation: _checkAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(40, 40),
                painter: _CheckPainter(
                  progress: _checkAnimation.value,
                  color: AppTheme.primaryColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CheckPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 4;

    final path = Path();

    // Start point of the checkmark
    final startPoint = Offset(size.width * 0.2, size.height * 0.5);

    // Middle point of the checkmark
    final middlePoint = Offset(size.width * 0.4, size.height * 0.7);

    // End point of the checkmark
    final endPoint = Offset(size.width * 0.8, size.height * 0.3);

    // Draw the first part of the checkmark (start to middle)
    if (progress <= 0.5) {
      final firstSegmentProgress = progress * 2; // Scale to 0-1 for first half

      final currentMiddleX = startPoint.dx +
          (middlePoint.dx - startPoint.dx) * firstSegmentProgress;
      final currentMiddleY = startPoint.dy +
          (middlePoint.dy - startPoint.dy) * firstSegmentProgress;

      path.moveTo(startPoint.dx, startPoint.dy);
      path.lineTo(currentMiddleX, currentMiddleY);
    } else {
      // Draw the complete first segment
      path.moveTo(startPoint.dx, startPoint.dy);
      path.lineTo(middlePoint.dx, middlePoint.dy);

      // Draw the second part of the checkmark (middle to end)
      final secondSegmentProgress =
          (progress - 0.5) * 2; // Scale to 0-1 for second half

      final currentEndX = middlePoint.dx +
          (endPoint.dx - middlePoint.dx) * secondSegmentProgress;
      final currentEndY = middlePoint.dy +
          (endPoint.dy - middlePoint.dy) * secondSegmentProgress;

      path.lineTo(currentEndX, currentEndY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
