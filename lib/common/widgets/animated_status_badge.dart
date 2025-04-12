//
import 'package:flutter/material.dart';
import '../../../data/models/task_model.dart';

class AnimatedStatusBadge extends StatelessWidget {
  final TaskStatus status;
  final double height;
  final double? width;
  final bool showIcon;
  final bool showText;

  const AnimatedStatusBadge({
    Key? key,
    required this.status,
    this.height = 28.0,
    this.width,
    this.showIcon = true,
    this.showText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig(status);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: height,
      width: width,
      padding: EdgeInsets.symmetric(
        horizontal: showText ? 12.0 : height * 0.2,
        vertical: height * 0.1,
      ),
      decoration: BoxDecoration(
        color: statusConfig.bgColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(height * 0.5),
        border: Border.all(
          color: statusConfig.bgColor.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showIcon) ...[
            Icon(
              statusConfig.icon,
              color: statusConfig.bgColor,
              size: height * 0.6,
            ),
            if (showText) const SizedBox(width: 6),
          ],
          if (showText)
            Text(
              statusConfig.text,
              style: TextStyle(
                color: statusConfig.textColor,
                fontWeight: FontWeight.w600,
                fontSize: height * 0.45,
              ),
            ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return _StatusConfig(
          bgColor: Colors.blue,
          textColor: Colors.blue.shade800,
          icon: Icons.hourglass_empty,
          text: 'To Do',
        );
      case TaskStatus.inProgress:
        return _StatusConfig(
          bgColor: Colors.amber,
          textColor: Colors.amber.shade900,
          icon: Icons.engineering,
          text: 'In Progress',
        );
      case TaskStatus.done:
        return _StatusConfig(
          bgColor: Colors.green,
          textColor: Colors.green.shade800,
          icon: Icons.check_circle,
          text: 'Completed',
        );
    }
  }
}

class _StatusConfig {
  final Color bgColor;
  final Color textColor;
  final IconData icon;
  final String text;

  _StatusConfig({
    required this.bgColor,
    required this.textColor,
    required this.icon,
    required this.text,
  });
}
