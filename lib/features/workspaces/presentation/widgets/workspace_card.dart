// lib/features/workspaces/presentation/widgets/workspace_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme.dart';
import '../../../../common/widgets/animated_card.dart';
import '../../../../data/models/workspace_model.dart';

class WorkspaceCard extends StatefulWidget {
  final WorkspaceModel workspace;
  final VoidCallback onTap;

  const WorkspaceCard({
    Key? key,
    required this.workspace,
    required this.onTap,
  }) : super(key: key);

  @override
  State<WorkspaceCard> createState() => _WorkspaceCardState();
}

class _WorkspaceCardState extends State<WorkspaceCard>
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

  String _getMembersPreview() {
    if (widget.workspace.members.isEmpty) {
      return 'No members';
    }

    final List<String> names = widget.workspace.members
        .take(3)
        .map((m) => m.user.name.split(' ')[0])
        .toList();

    int remaining = widget.workspace.members.length - 3;

    if (remaining > 0) {
      return '${names.join(', ')} and $remaining more';
    } else {
      return names.join(', ');
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  Color _getRandomColor() {
    final List<Color> colors = [
      const Color(0xFF536DFE), // Primary
      const Color(0xFF42A5F5), // Secondary
      const Color(0xFF66BB6A), // Success
      const Color(0xFFEF5350), // Error
      const Color(0xFFFFCA28), // Warning
      const Color(0xFF9575CD), // Purple
      const Color(0xFF4DD0E1), // Cyan
      const Color(0xFFFF8A65), // Orange
    ];

    // Use the hash code of the workspace ID to select a consistent color
    int index = widget.workspace.id.hashCode % colors.length;
    return colors[index.abs()];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getRandomColor();

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedCard(
        margin: const EdgeInsets.only(bottom: 16),
        backgroundColor: theme.cardColor,
        onTap: widget.onTap,
        elevation: _isHovered ? 4 : 2,
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        child: Stack(
          children: [
            // Decorative circle in the background
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.1),
                ),
              ),
            ),

            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Workspace icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          widget.workspace.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Workspace name and members
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.workspace.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getMembersPreview(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Arrow icon with animation
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_animation.value * 8, 0),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: _isHovered
                                ? AppTheme.primaryColor
                                : Colors.grey.shade400,
                            size: 16,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Description
                if (widget.workspace.description.isNotEmpty)
                  Text(
                    widget.workspace.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 16),
                // Stats
                Row(
                  children: [
                    _StatItem(
                      icon: Icons.people_outline,
                      value: widget.workspace.members.length.toString(),
                      label: 'Members',
                      color: color,
                    ),
                    const SizedBox(width: 16),
                    _StatItem(
                      icon: Icons.calendar_today_outlined,
                      value: _formatDate(widget.workspace.createdAt),
                      label: 'Created',
                      color: color,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color.withOpacity(0.8),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
