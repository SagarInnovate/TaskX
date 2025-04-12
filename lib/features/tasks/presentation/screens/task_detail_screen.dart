// lib/features/tasks/presentation/screens/task_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme.dart';
import '../../../../common/widgets/animated_button.dart';
import '../../../../common/widgets/animated_status_badge.dart';
import '../../../../common/widgets/futuristic_text_field.dart';
import '../../../../data/models/task_model.dart'; // Import the task model
import '../../../../data/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../widgets/task_comment_item.dart';
import '../widgets/task_attachment_item.dart';

class TaskDetailScreen extends StatefulWidget {
  final String? taskId;

  const TaskDetailScreen({
    Key? key,
    this.taskId,
  }) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _commentController = TextEditingController();
  bool _isLoading = true;
  bool _isUpdating = false;
  bool _isAddingComment = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();

    // Load task details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTaskDetails();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTaskDetails() async {
    if (widget.taskId == null) {
      _showErrorAndNavigateBack('Task ID is missing');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      // Load task
      final success = await taskProvider.getTaskById(widget.taskId!);
      if (!success) {
        _showErrorAndNavigateBack('Task not found');
        return;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _showErrorAndNavigateBack('Failed to load task: $e');
    }
  }

  void _showErrorAndNavigateBack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );

    Navigator.of(context).pop();
  }

  Future<void> _updateTaskStatus(TaskStatus newStatus) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final currentTask = taskProvider.currentTask;

    if (currentTask == null || _isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final success =
          await taskProvider.updateTaskStatus(currentTask.id, newStatus);

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                taskProvider.errorMessage ?? 'Failed to update task status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating task status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _addComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty || _isAddingComment) return;

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentTask = taskProvider.currentTask;
    final currentUser = authProvider.user;

    if (currentTask == null || currentUser == null) return;

    setState(() {
      _isAddingComment = true;
    });

    try {
      final success = await taskProvider.addComment(
        taskId: currentTask.id,
        content: comment,
        user: currentUser,
      );

      if (success && mounted) {
        _commentController.clear();
        FocusScope.of(context).unfocus();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(taskProvider.errorMessage ?? 'Failed to add comment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingComment = false;
        });
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No due date';
    return DateFormat('EEE, MMM d, yyyy • h:mm a').format(date);
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red.shade700;
      case TaskPriority.medium:
        return Colors.orange.shade700;
      case TaskPriority.low:
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'High Priority';
      case TaskPriority.medium:
        return 'Medium Priority';
      case TaskPriority.low:
        return 'Low Priority';
      default:
        return '';
    }
  }

  bool _isOverdue(DateTime? dueDate) {
    return dueDate != null && dueDate.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final task = taskProvider.currentTask;
    final isCurrentUserAssignee = task?.assignedTo == authProvider.user?.id;

    return Scaffold(
      body: _isLoading || task == null
          ? _buildLoadingState()
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        children: [
                          // Back button
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Task title
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Task Details',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  task.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Status badge
                          AnimatedStatusBadge(
                            status: task.status,
                            showText: true,
                            showIcon: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Task details and comments
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          // Task description
                          if (task.description.isNotEmpty) ...[
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                task.description,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade800,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Task metadata
                          const Text(
                            'Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Due date
                                _buildDetailRow(
                                  icon: Icons.calendar_today,
                                  iconColor: _isOverdue(task.dueDate)
                                      ? Colors.red
                                      : Colors.blue,
                                  title: 'Due Date',
                                  value: _formatDate(task.dueDate),
                                  valueColor: _isOverdue(task.dueDate)
                                      ? Colors.red
                                      : null,
                                ),
                                const SizedBox(height: 12),

                                // Priority
                                _buildDetailRow(
                                  icon: Icons.flag,
                                  iconColor: _getPriorityColor(task.priority),
                                  title: 'Priority',
                                  value: _getPriorityText(task.priority),
                                  valueColor: _getPriorityColor(task.priority),
                                ),
                                const SizedBox(height: 12),

                                // Assignee
                                _buildDetailRow(
                                  icon: Icons.person,
                                  iconColor: isCurrentUserAssignee
                                      ? AppTheme.primaryColor
                                      : Colors.purple,
                                  title: 'Assigned To',
                                  value: isCurrentUserAssignee
                                      ? 'You'
                                      : 'Other User', // In a real app, fetch the user name
                                ),
                                const SizedBox(height: 12),

                                // Created info
                                _buildDetailRow(
                                  icon: Icons.access_time,
                                  iconColor: Colors.grey.shade700,
                                  title: 'Created',
                                  value: _formatDate(task.createdAt),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Attachments
                          if (task.attachments.isNotEmpty) ...[
                            const Text(
                              'Attachments',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: task.attachments.map((attachment) {
                                  return TaskAttachmentItem(
                                    attachment: attachment,
                                    onTap: () {
                                      // In a real app, open the attachment
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Status changer
                          const Text(
                            'Change Status',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatusButton(
                                  label: 'To Do',
                                  icon: Icons.hourglass_empty,
                                  color: Colors.blue,
                                  isSelected: task.status == TaskStatus.todo,
                                  onPressed: () =>
                                      _updateTaskStatus(TaskStatus.todo),
                                ),
                                _buildStatusButton(
                                  label: 'In Progress',
                                  icon: Icons.engineering,
                                  color: Colors.amber,
                                  isSelected:
                                      task.status == TaskStatus.inProgress,
                                  onPressed: () =>
                                      _updateTaskStatus(TaskStatus.inProgress),
                                ),
                                _buildStatusButton(
                                  label: 'Done',
                                  icon: Icons.check_circle,
                                  color: Colors.green,
                                  isSelected: task.status == TaskStatus.done,
                                  onPressed: () =>
                                      _updateTaskStatus(TaskStatus.done),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Comments
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Comments',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${task.comments.length} ${task.comments.length == 1 ? 'comment' : 'comments'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Comments list
                          ...task.comments.map((comment) {
                            final isCurrentUserComment =
                                comment.userId == authProvider.user?.id;
                            return TaskCommentItem(
                              comment: comment,
                              isCurrentUserComment: isCurrentUserComment,
                              onAddReaction: (reaction) {
                                // In a real app, add reaction to comment
                              },
                            );
                          }).toList(),

                          // Empty space at bottom
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),

                  // Comment input
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Attachment button
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.attach_file,
                                color: Colors.grey.shade700,
                                size: 20,
                              ),
                              onPressed: () {
                                // In a real app, show attachment options
                              },
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Comment input
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextField(
                                controller: _commentController,
                                decoration: InputDecoration(
                                  hintText: 'Add a comment...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                                maxLines: 1,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _addComment(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Send button
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: _isAddingComment
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                              onPressed: _isAddingComment ? null : _addComment,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return const SafeArea(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: _isUpdating ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
