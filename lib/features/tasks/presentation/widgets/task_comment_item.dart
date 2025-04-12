// lib/features/tasks/presentation/widgets/task_comment_item.dart
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../app/theme.dart';
import '../../../../data/models/task_model.dart';

class TaskCommentItem extends StatefulWidget {
  final TaskComment comment;
  final bool isCurrentUserComment;
  final Function(String) onAddReaction;

  const TaskCommentItem({
    Key? key,
    required this.comment,
    required this.isCurrentUserComment,
    required this.onAddReaction,
  }) : super(key: key);

  @override
  State<TaskCommentItem> createState() => _TaskCommentItemState();
}

class _TaskCommentItemState extends State<TaskCommentItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _showReactions = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
      setState(() {
        _showReactions = false;
      });
    }
  }

  void _toggleReactions() {
    setState(() {
      _showReactions = !_showReactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(
                  left: widget.isCurrentUserComment ? 40 : 0,
                  right: widget.isCurrentUserComment ? 0 : 40,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.isCurrentUserComment
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isCurrentUserComment
                        ? AppTheme.primaryColor.withOpacity(0.3)
                        : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Comment header
                    Row(
                      children: [
                        // User avatar
                        if (!widget.isCurrentUserComment) _buildAvatar(),
                        if (!widget.isCurrentUserComment)
                          const SizedBox(width: 8),

                        // User name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: widget.isCurrentUserComment
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.isCurrentUserComment
                                    ? 'You'
                                    : widget.comment.userName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: widget.isCurrentUserComment
                                      ? AppTheme.primaryColor
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                timeago.format(widget.comment.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (widget.isCurrentUserComment)
                          const SizedBox(width: 8),

                        // User avatar
                        if (widget.isCurrentUserComment) _buildAvatar(),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Comment content
                    Text(
                      widget.comment.content,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade800,
                        height: 1.5,
                      ),
                    ),

                    // Reactions
                    if (widget.comment.reactions.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildReactions(),
                    ],
                  ],
                ),
              ),

              // Reaction button
              if (_isHovered)
                Positioned(
                  right: widget.isCurrentUserComment ? 12 : null,
                  left: widget.isCurrentUserComment ? null : 12,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: _toggleReactions,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add_reaction,
                        size: 18,
                        color: _showReactions
                            ? AppTheme.primaryColor
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),

              // Reactions picker
              if (_showReactions)
                Positioned(
                  right: widget.isCurrentUserComment ? 40 : null,
                  left: widget.isCurrentUserComment ? null : 40,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildReactionButton('👍'),
                        _buildReactionButton('❤️'),
                        _buildReactionButton('😊'),
                        _buildReactionButton('🎉'),
                        _buildReactionButton('😂'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (widget.comment.userPhotoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: NetworkImage(widget.comment.userPhotoUrl),
        onBackgroundImageError: (_, __) {
          // Handle image error
        },
      );
    } else {
      return CircleAvatar(
        radius: 16,
        backgroundColor: _getAvatarColor(),
        child: Text(
          _getInitials(widget.comment.userName),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  Widget _buildReactionButton(String emoji) {
    return GestureDetector(
      onTap: () {
        widget.onAddReaction(emoji);
        setState(() {
          _showReactions = false;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          emoji,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildReactions() {
    return Wrap(
      spacing: 8,
      children: widget.comment.reactions.map((reaction) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Text(
            reaction,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}';
    } else if (name.isNotEmpty) {
      return name[0];
    } else {
      return '?';
    }
  }

  Color _getAvatarColor() {
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    // Use hash of user ID for consistent color
    final int colorIndex = widget.comment.userId.hashCode % colors.length;
    return colors[colorIndex.abs()];
  }
}
