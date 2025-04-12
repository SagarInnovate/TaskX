// lib/features/tasks/providers/task_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../data/services/task_service.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/user_model.dart';

enum TaskProviderStatus {
  initial,
  loading,
  loaded,
  creating,
  updating,
  error,
}

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<TaskModel> _tasks = [];
  TaskModel? _currentTask;
  TaskProviderStatus _status = TaskProviderStatus.initial;
  String? _errorMessage;
  StreamSubscription<List<TaskModel>>? _tasksSubscription;

  List<TaskModel> get tasks => _tasks;
  TaskModel? get currentTask => _currentTask;
  TaskProviderStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<TaskModel> get todoTasks =>
      _tasks.where((task) => task.status == TaskStatus.todo).toList();

  List<TaskModel> get inProgressTasks =>
      _tasks.where((task) => task.status == TaskStatus.inProgress).toList();

  List<TaskModel> get doneTasks =>
      _tasks.where((task) => task.status == TaskStatus.done).toList();

  void loadWorkspaceTasks(String workspaceId) {
    _status = TaskProviderStatus.loading;
    notifyListeners();

    // Cancel previous subscription if exists
    _tasksSubscription?.cancel();

    // Subscribe to task updates
    _tasksSubscription = _taskService.getWorkspaceTasks(workspaceId).listen(
      (tasks) {
        _tasks = tasks;
        _status = TaskProviderStatus.loaded;

        // If current task is in the list, update it
        if (_currentTask != null) {
          final updatedTask = _tasks.firstWhere(
            (task) => task.id == _currentTask!.id,
            orElse: () => _currentTask!,
          );
          _currentTask = updatedTask;
        }

        notifyListeners();
      },
      onError: (error) {
        _status = TaskProviderStatus.error;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  void loadUserTasks(String userId) {
    _status = TaskProviderStatus.loading;
    notifyListeners();

    // Cancel previous subscription if exists
    _tasksSubscription?.cancel();

    // Subscribe to task updates
    _tasksSubscription = _taskService.getUserTasks(userId).listen(
      (tasks) {
        _tasks = tasks;
        _status = TaskProviderStatus.loaded;
        notifyListeners();
      },
      onError: (error) {
        _status = TaskProviderStatus.error;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> createTask({
    required String title,
    required String description,
    required String workspaceId,
    required String createdBy,
    required String assignedTo,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
  }) async {
    try {
      _status = TaskProviderStatus.creating;
      notifyListeners();

      final task = await _taskService.createTask(
        title: title,
        description: description,
        workspaceId: workspaceId,
        createdBy: createdBy,
        assignedTo: assignedTo,
        dueDate: dueDate,
        priority: priority,
      );

      if (task != null) {
        _currentTask = task;
        _status = TaskProviderStatus.loaded;
        notifyListeners();
        return true;
      } else {
        _status = TaskProviderStatus.error;
        _errorMessage = 'Failed to create task';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = TaskProviderStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> getTaskById(String taskId) async {
    try {
      _status = TaskProviderStatus.loading;
      notifyListeners();

      final task = await _taskService.getTask(taskId);

      if (task != null) {
        _currentTask = task;
        _status = TaskProviderStatus.loaded;
        notifyListeners();
        return true;
      } else {
        _status = TaskProviderStatus.error;
        _errorMessage = 'Task not found';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = TaskProviderStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void selectTask(TaskModel task) {
    _currentTask = task;
    notifyListeners();
  }

  Future<bool> updateTask(TaskModel task) async {
    try {
      _status = TaskProviderStatus.updating;
      notifyListeners();

      final success = await _taskService.updateTask(task);

      if (success) {
        _currentTask = task;
        _status = TaskProviderStatus.loaded;
        notifyListeners();
        return true;
      } else {
        _status = TaskProviderStatus.error;
        _errorMessage = 'Failed to update task';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = TaskProviderStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      _status = TaskProviderStatus.updating;
      notifyListeners();

      final success = await _taskService.updateTaskStatus(taskId, status);

      if (success) {
        if (_currentTask?.id == taskId) {
          _currentTask = _currentTask!.copyWith(status: status);
        }
        _status = TaskProviderStatus.loaded;
        notifyListeners();
        return true;
      } else {
        _status = TaskProviderStatus.error;
        _errorMessage = 'Failed to update task status';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = TaskProviderStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addComment({
    required String taskId,
    required String content,
    required UserModel user,
  }) async {
    try {
      _status = TaskProviderStatus.updating;
      notifyListeners();

      final success = await _taskService.addComment(
        taskId: taskId,
        content: content,
        user: user,
      );

      if (success) {
        _status = TaskProviderStatus.loaded;
        notifyListeners();
        return true;
      } else {
        _status = TaskProviderStatus.error;
        _errorMessage = 'Failed to add comment';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = TaskProviderStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addAttachment({
    required String taskId,
    required String name,
    required String url,
    required String type,
    required String uploadedBy,
  }) async {
    try {
      _status = TaskProviderStatus.updating;
      notifyListeners();

      final success = await _taskService.addAttachment(
        taskId: taskId,
        name: name,
        url: url,
        type: type,
        uploadedBy: uploadedBy,
      );

      if (success) {
        _status = TaskProviderStatus.loaded;
        notifyListeners();
        return true;
      } else {
        _status = TaskProviderStatus.error;
        _errorMessage = 'Failed to add attachment';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = TaskProviderStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addReactionToComment({
    required String taskId,
    required String commentId,
    required String reaction,
  }) async {
    try {
      final success = await _taskService.addReactionToComment(
        taskId: taskId,
        commentId: commentId,
        reaction: reaction,
      );

      if (success) {
        // No need to update status since this is a minor update
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error adding reaction: $e');
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      _status = TaskProviderStatus.updating;
      notifyListeners();

      final success = await _taskService.deleteTask(taskId);

      if (success) {
        if (_currentTask?.id == taskId) {
          _currentTask = null;
        }
        _status = TaskProviderStatus.loaded;
        notifyListeners();
        return true;
      } else {
        _status = TaskProviderStatus.error;
        _errorMessage = 'Failed to delete task';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = TaskProviderStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
