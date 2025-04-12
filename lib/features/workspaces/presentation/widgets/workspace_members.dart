// lib/features/workspaces/presentation/widgets/workspace_members.dart
import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../../data/models/workspace_model.dart';

class WorkspaceMembers extends StatelessWidget {
  final List<WorkspaceMember> members;
  final int maxDisplayed;
  final VoidCallback? onViewAll;

  const WorkspaceMembers({
    Key? key,
    required this.members,
    this.maxDisplayed = 5,
    this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Members',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (members.length > maxDisplayed && onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: members.length <= maxDisplayed
                ? members.length + 1 // +1 for add button
                : maxDisplayed +
                    2, // +1 for add button and +1 for overflow indicator
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildAddMemberButton(context);
              } else if (index <= maxDisplayed && index <= members.length) {
                return _buildMemberAvatar(members[index - 1], index - 1);
              } else {
                return _buildOverflowIndicator(members.length - maxDisplayed);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddMemberButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.add,
          color: AppTheme.primaryColor,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildMemberAvatar(WorkspaceMember member, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: _MemberAvatar(
        member: member,
        showRole: index < 3, // Only show role for first 3 members
      ),
    );
  }

  Widget _buildOverflowIndicator(int remaining) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '+$remaining',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberAvatar extends StatefulWidget {
  final WorkspaceMember member;
  final bool showRole;

  const _MemberAvatar({
    Key? key,
    required this.member,
    this.showRole = false,
  }) : super(key: key);

  @override
  State<_MemberAvatar> createState() => _MemberAvatarState();
}

class _MemberAvatarState extends State<_MemberAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
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

  Color _getRoleColor() {
    switch (widget.member.role) {
      case WorkspaceRole.owner:
        return Colors.deepPurple;
      case WorkspaceRole.admin:
        return Colors.blue;
      case WorkspaceRole.member:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getRoleText() {
    switch (widget.member.role) {
      case WorkspaceRole.owner:
        return 'Owner';
      case WorkspaceRole.admin:
        return 'Admin';
      case WorkspaceRole.member:
        return 'Member';
      default:
        return '';
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
                border: _isHovered
                    ? Border.all(
                        color: _getRoleColor(),
                        width: 2,
                      )
                    : null,
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: _getRoleColor().withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: ClipOval(
                child: widget.member.user.photoUrl.isNotEmpty
                    ? Image.network(
                        widget.member.user.photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildInitials(),
                      )
                    : _buildInitials(),
              ),
            ),
            // Role indicator
            if (widget.showRole && widget.member.role != WorkspaceRole.member)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: _getRoleColor(),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            // Tooltip on hover
            if (_isHovered)
              Positioned(
                bottom: -40,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.member.user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _getRoleText(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
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

  Widget _buildInitials() {
    final name = widget.member.user.name;
    final initials =
        name.isNotEmpty ? name.split(' ').map((e) => e[0]).take(2).join() : '?';

    return Container(
      color: _getAvatarColor(),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
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
    final int colorIndex = widget.member.user.id.hashCode % colors.length;
    return colors[colorIndex.abs()];
  }
}
