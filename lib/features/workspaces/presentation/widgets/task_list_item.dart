// lib/features/workspaces/presentation/widgets/task_list_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../app/theme.dart';
import '../../../../common/widgets/animated_card.dart';
import '../../../../common/widgets/animated_status_badge.dart';
import '../../../../data/models/task_model.dart';

class TaskListItem extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final String currentUserId;

  const TaskListItem({
    Key? key,
    required this.task,
    required this.onTap,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<TaskListItem> createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  Color _getPriorityColor() {
    switch (widget.task.priority) {
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

  String _getPriorityText() {
    switch (widget.task.priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
      default:
        return '';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No due date';

    // If the date is today
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today, ${DateFormat('hh:mm a').format(date)}';
    }

    // If the date is tomorrow
    final tomorrow = now.add(const Duration(days: 1));
    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow, ${DateFormat('hh:mm a').format(date)}';
    }

    // If the date is within a week
    if (date.difference(now).inDays < 7) {
      return DateFormat('EEEE, hh:mm a').format(date); // e.g. Monday, 03:30 PM
    }

    // Otherwise, show full date
    return DateFormat('MMM d, yyyy').format(date);
  }

  bool _isOverdue() {
    return widget.task.dueDate != null &&
        widget.task.dueDate!.isBefore(DateTime.now()) &&
        widget.task.status != TaskStatus.done;
  }

  @override
  Widget build(BuildContext context) {
    final isAssignedToCurrentUser =
        widget.task.assignedTo == widget.currentUserId;
    final hasComments = widget.task.comments.isNotEmpty;
    final hasAttachments = widget.task.attachments.isNotEmpty;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedCard(
        margin: const EdgeInsets.only(bottom: 16),
        onTap: widget.onTap,
        elevation: _isHovered ? 4 : 2,
        backgroundColor: _isHovered
            ? Theme.of(context).cardColor.withOpacity(0.95)
            : Theme.of(context).cardColor,
        border: Border.all(
          color: _isHovered
              ? AppTheme.primaryColor.withOpacity(0.3)
              : Colors.grey.shade200,
          width: _isHovered ? 1.5 : 1,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Status badge
                    AnimatedStatusBadge(status: widget.task.status),
                    const SizedBox(width: 12),

                    // Priority indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _getPriorityColor().withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.flag,
                            size: 12,
                            color: _getPriorityColor(),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getPriorityText(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getPriorityColor(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Due date
                    if (widget.task.dueDate != null)
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: _isOverdue()
                                ? Colors.red
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(widget.task.dueDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: _isOverdue()
                                  ? Colors.red
                                  : Colors.grey.shade600,
                              fontWeight: _isOverdue()
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Task title
                Text(
                  widget.task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: widget.task.status == TaskStatus.done
                        ? TextDecoration.lineThrough
                        : null,
                    color: widget.task.status == TaskStatus.done
                        ? Colors.grey.shade500
                        : Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                // Task description
                if (widget.task.description.isNotEmpty)
                  Text(
                    widget.task.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 12),

                // Task metadata (comments, attachments, created)
                Row(
                  children: [
                    // Assigned to indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isAssignedToCurrentUser
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 12,
                            color: isAssignedToCurrentUser
                                ? AppTheme.primaryColor
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isAssignedToCurrentUser ? 'You' : 'Other',
                            style: TextStyle(
                              fontSize: 12,
                              color: isAssignedToCurrentUser
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Comments count
                    if (hasComments)
                      Row(
                        children: [
                          Icon(
                            Icons.comment,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.task.comments.length.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                    if (hasComments && hasAttachments)
                      const SizedBox(width: 12),

                    // Attachments count
                    if (hasAttachments)
                      Row(
                        children: [
                          Icon(
                            Icons.attach_file,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.task.attachments.length.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                    const Spacer(),

                    // Created at
                    Text(
                      'Created ${timeago.format(widget.task.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Right arrow on hover
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Positioned(
                  right: -10 + (20 * _animation.value),
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor
                            .withOpacity(_animation.value * 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color:
                            AppTheme.primaryColor.withOpacity(_animation.value),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
