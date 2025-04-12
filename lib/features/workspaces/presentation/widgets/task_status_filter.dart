// lib/features/workspaces/presentation/widgets/task_status_filter.dart
import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../../data/models/task_model.dart';

class TaskStatusFilter extends StatelessWidget {
  final TaskStatus selectedStatus;
  final Function(TaskStatus) onStatusSelected;
  final int todoCount;
  final int inProgressCount;
  final int doneCount;

  const TaskStatusFilter({
    Key? key,
    required this.selectedStatus,
    required this.onStatusSelected,
    required this.todoCount,
    required this.inProgressCount,
    required this.doneCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _buildFilterOption(
            context,
            status: TaskStatus.todo,
            label: 'To Do',
            count: todoCount,
            icon: Icons.hourglass_empty,
            color: Colors.blue,
          ),
          _buildFilterOption(
            context,
            status: TaskStatus.inProgress,
            label: 'In Progress',
            count: inProgressCount,
            icon: Icons.engineering,
            color: Colors.amber,
          ),
          _buildFilterOption(
            context,
            status: TaskStatus.done,
            label: 'Done',
            count: doneCount,
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context, {
    required TaskStatus status,
    required String label,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = selectedStatus == status;

    return Expanded(
      child: GestureDetector(
        onTap: () => onStatusSelected(status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? color : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? color : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              if (count > 0)
                Positioned(
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
