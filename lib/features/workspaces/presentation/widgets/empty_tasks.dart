// lib/features/workspaces/presentation/widgets/empty_tasks.dart
import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../../common/widgets/animated_button.dart' ;
import '../../../../data/models/task_model.dart';

class EmptyTasks extends StatefulWidget {
  final TaskStatus selectedStatus;
  final VoidCallback onCreateTask;

  const EmptyTasks({
    Key? key,
    required this.selectedStatus,
    required this.onCreateTask,
  }) : super(key: key);

  @override
  State<EmptyTasks> createState() => _EmptyTasksState();
}

class _EmptyTasksState extends State<EmptyTasks>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getEmptyStateTitle() {
    switch (widget.selectedStatus) {
      case TaskStatus.todo:
        return 'No Tasks to Do';
      case TaskStatus.inProgress:
        return 'No Tasks in Progress';
      case TaskStatus.done:
        return 'No Completed Tasks';
      default:
        return 'No Tasks';
    }
  }

  String _getEmptyStateDescription() {
    switch (widget.selectedStatus) {
      case TaskStatus.todo:
        return 'Start by creating a new task to get your work organized.';
      case TaskStatus.inProgress:
        return 'Move tasks from To Do to In Progress to start working on them.';
      case TaskStatus.done:
        return 'Completed tasks will appear here. Keep up the good work!';
      default:
        return 'Create your first task to get started.';
    }
  }

  IconData _getEmptyStateIcon() {
    switch (widget.selectedStatus) {
      case TaskStatus.todo:
        return Icons.assignment_add;
      case TaskStatus.inProgress:
        return Icons.engineering;
      case TaskStatus.done:
        return Icons.check_circle_outline;
      default:
        return Icons.task_alt;
    }
  }

  Color _getEmptyStateColor() {
    switch (widget.selectedStatus) {
      case TaskStatus.todo:
        return Colors.blue;
      case TaskStatus.inProgress:
        return Colors.amber;
      case TaskStatus.done:
        return Colors.green;
      default:
        return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
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
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _EmptyTasksIllustration(
                icon: _getEmptyStateIcon(),
                color: _getEmptyStateColor(),
              ),
              const SizedBox(height: 24),
              Text(
                _getEmptyStateTitle(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _getEmptyStateColor(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _getEmptyStateDescription(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              widget.selectedStatus == TaskStatus.todo
                  ? AnimatedButton(
                      text: 'Create Task',
                      onPressed: widget.onCreateTask,
                      icon: Icons.add,
                      style: AppButtonStyle.primary,
                      width: 200,
                      height: 48,
                    )
                  : AnimatedButton(
                      text: 'Switch to To Do',
                      onPressed: () {
                        // This will be handled by the parent to update the filter
                      },
                      style: AppButtonStyle.ghost,
                      width: 200,
                      height: 48,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTasksIllustration extends StatefulWidget {
  final IconData icon;
  final Color color;

  const _EmptyTasksIllustration({
    Key? key,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  State<_EmptyTasksIllustration> createState() =>
      _EmptyTasksIllustrationState();
}

class _EmptyTasksIllustrationState extends State<_EmptyTasksIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    size: 40,
                    color: widget.color,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
