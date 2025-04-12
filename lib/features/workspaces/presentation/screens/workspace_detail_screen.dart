// lib/features/workspaces/presentation/screens/workspace_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../common/widgets/animated_button.dart';
import '../../../../common/widgets/animated_card.dart';
import '../../../../common/widgets/shimmer_loading.dart';
import '../../../../data/models/task_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../tasks/providers/task_provider.dart';
import '../../providers/workspace_provider.dart';
import '../widgets/task_list_item.dart';
import '../widgets/task_status_filter.dart';
import '../widgets/workspace_members.dart';
import '../widgets/empty_tasks.dart';

class WorkspaceDetailScreen extends StatefulWidget {
  final String? workspaceId;

  const WorkspaceDetailScreen({
    Key? key,
    this.workspaceId,
  }) : super(key: key);

  @override
  State<WorkspaceDetailScreen> createState() => _WorkspaceDetailScreenState();
}

class _WorkspaceDetailScreenState extends State<WorkspaceDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  TaskStatus _selectedStatus = TaskStatus.todo;
  bool _isLoading = true;

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

    // Load workspace details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWorkspaceDetails();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkspaceDetails() async {
    if (widget.workspaceId == null) {
      _showErrorAndNavigateBack('Workspace ID is missing');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final workspaceProvider =
          Provider.of<WorkspaceProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      // Load workspace
      final success =
          await workspaceProvider.getWorkspaceById(widget.workspaceId!);
      if (!success) {
        _showErrorAndNavigateBack('Workspace not found');
        return;
      }

      // Load tasks for this workspace
      taskProvider.loadWorkspaceTasks(widget.workspaceId!);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _showErrorAndNavigateBack('Failed to load workspace: $e');
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

  void _createNewTask() {
    AppRoutes.navigateTo(
      context,
      AppRoutes.createTask,
      arguments: {'workspaceId': widget.workspaceId},
    );
  }

  void _navigateToTaskDetail(String taskId) {
    AppRoutes.navigateTo(
      context,
      AppRoutes.taskDetail,
      arguments: {'taskId': taskId},
    );
  }

  void _updateStatusFilter(TaskStatus status) {
    setState(() {
      _selectedStatus = status;
    });
  }

  List<TaskModel> _getFilteredTasks(TaskProvider taskProvider) {
    switch (_selectedStatus) {
      case TaskStatus.todo:
        return taskProvider.todoTasks;
      case TaskStatus.inProgress:
        return taskProvider.inProgressTasks;
      case TaskStatus.done:
        return taskProvider.doneTasks;
      default:
        return taskProvider.tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final workspaceProvider = Provider.of<WorkspaceProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final workspace = workspaceProvider.currentWorkspace;

    return Scaffold(
      body: _isLoading || workspace == null
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
                          // Workspace info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  workspace.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${workspace.members.length} members · ${taskProvider.tasks.length} tasks',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Members row
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: WorkspaceMembers(members: workspace.members),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Task filters
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TaskStatusFilter(
                        selectedStatus: _selectedStatus,
                        onStatusSelected: _updateStatusFilter,
                        todoCount: taskProvider.todoTasks.length,
                        inProgressCount: taskProvider.inProgressTasks.length,
                        doneCount: taskProvider.doneTasks.length,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Task list
                  Expanded(
                    child: _buildTaskList(taskProvider, authProvider),
                  ),
                ],
              ),
            ),
      floatingActionButton: !_isLoading
          ? ScaleTransition(
              scale: _fadeAnimation,
              child: FloatingActionButton.extended(
                onPressed: _createNewTask,
                icon: const Icon(Icons.add),
                label: const Text('New Task'),
                elevation: 2,
              ),
            )
          : null,
    );
  }

  Widget _buildLoadingState() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
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
                Expanded(
                  child: ShimmerLoading(
                    isLoading: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 14,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Members loading
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ShimmerLoading(
              isLoading: true,
              child: Row(
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Filter loading
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ShimmerLoading(
              isLoading: true,
              child: Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Task list loading
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 5,
              itemBuilder: (context, index) {
                return ShimmerLoading(
                  isLoading: true,
                  child: AnimatedCard(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.zero,
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(TaskProvider taskProvider, AuthProvider authProvider) {
    final filteredTasks = _getFilteredTasks(taskProvider);

    if (taskProvider.status == TaskProviderStatus.loading) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 5,
        itemBuilder: (context, index) {
          return ShimmerLoading(
            isLoading: true,
            child: AnimatedCard(
              margin: const EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.zero,
              child: Container(
                height: 100,
                width: double.infinity,
                color: Colors.white,
              ),
            ),
          );
        },
      );
    }

    if (filteredTasks.isEmpty) {
      return EmptyTasks(
        selectedStatus: _selectedStatus,
        onCreateTask: _createNewTask,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  0.5 + (index * 0.1 > 0.5 ? 0.5 : index * 0.1),
                  1.0,
                  curve: Curves.easeOut,
                ),
              ),
            ),
            child: TaskListItem(
              task: task,
              onTap: () => _navigateToTaskDetail(task.id),
              currentUserId: authProvider.user?.id ?? '',
            ),
          ),
        );
      },
    );
  }
}
