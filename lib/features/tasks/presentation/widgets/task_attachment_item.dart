// lib/features/tasks/presentation/widgets/task_attachment_item.dart
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../app/theme.dart';
import '../../../../data/models/task_model.dart';

class TaskAttachmentItem extends StatefulWidget {
  final TaskAttachment attachment;
  final VoidCallback onTap;

  const TaskAttachmentItem({
    Key? key,
    required this.attachment,
    required this.onTap,
  }) : super(key: key);

  @override
  State<TaskAttachmentItem> createState() => _TaskAttachmentItemState();
}

class _TaskAttachmentItemState extends State<TaskAttachmentItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

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
    }
  }

  IconData _getFileIcon() {
    switch (widget.attachment.type) {
      case 'voice':
        return Icons.mic;
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'document':
        return Icons.description;
      case 'pdf':
        return Icons.picture_as_pdf;
      default:
        return Icons.attach_file;
    }
  }

  Color _getIconColor() {
    switch (widget.attachment.type) {
      case 'voice':
        return Colors.purple;
      case 'image':
        return Colors.blue;
      case 'video':
        return Colors.red;
      case 'document':
        return Colors.green;
      case 'pdf':
        return Colors.orange;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  _isHovered ? _getIconColor().withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isHovered ? _getIconColor() : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // File icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getIconColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getFileIcon(),
                    color: _getIconColor(),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // File info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.attachment.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Uploaded ${timeago.format(widget.attachment.uploadedAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Download icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.download,
                      color: _isHovered
                          ? AppTheme.primaryColor
                          : Colors.grey.shade600,
                      size: 16,
                    ),
                    onPressed: widget.onTap,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
