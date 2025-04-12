// lib/data/services/task_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Collection reference
  CollectionReference get _tasksCollection => _firestore.collection('tasks');

  // Create task
  Future<TaskModel?> createTask({
    required String title,
    required String description,
    required String workspaceId,
    required String createdBy,
    required String assignedTo,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
  }) async {
    try {
      final String taskId = _uuid.v4();
      final now = DateTime.now();

      // Create task
      final task = TaskModel(
        id: taskId,
        title: title,
        description: description,
        createdAt: now,
        createdBy: createdBy,
        assignedTo: assignedTo,
        dueDate: dueDate,
        priority: priority,
        status: TaskStatus.todo,
        comments: [],
        attachments: [],
        workspaceId: workspaceId,
      );

      // Save to Firestore
      await _tasksCollection.doc(taskId).set(task.toJson());

      return task;
    } catch (e) {
      print('Error creating task: $e');
      return null;
    }
  }

  // Get task by ID
  Future<TaskModel?> getTask(String taskId) async {
    try {
      final DocumentSnapshot doc = await _tasksCollection.doc(taskId).get();

      if (!doc.exists) return null;

      return TaskModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting task: $e');
      return null;
    }
  }

  // Get tasks for workspace
  Stream<List<TaskModel>> getWorkspaceTasks(String workspaceId) {
    return _tasksCollection
        .where('workspaceId', isEqualTo: workspaceId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get tasks assigned to user
  Stream<List<TaskModel>> getUserTasks(String userId) {
    return _tasksCollection
        .where('assignedTo', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Update task
  Future<bool> updateTask(TaskModel task) async {
    try {
      await _tasksCollection.doc(task.id).update(task.toJson());
      return true;
    } catch (e) {
      print('Error updating task: $e');
      return false;
    }
  }

  // Update task status
  Future<bool> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      await _tasksCollection
          .doc(taskId)
          .update({'status': status.toString().split('.').last});
      return true;
    } catch (e) {
      print('Error updating task status: $e');
      return false;
    }
  }

  // Add comment to task
  Future<bool> addComment({
    required String taskId,
    required String content,
    required UserModel user,
  }) async {
    try {
      final String commentId = _uuid.v4();
      final now = DateTime.now();

      final comment = TaskComment(
        id: commentId,
        content: content,
        userId: user.id,
        userName: user.name,
        userPhotoUrl: user.photoUrl,
        createdAt: now,
        reactions: [],
      );

      await _tasksCollection.doc(taskId).update({
        'comments': FieldValue.arrayUnion([comment.toJson()]),
      });

      return true;
    } catch (e) {
      print('Error adding comment: $e');
      return false;
    }
  }

  // Add attachment to task
  Future<bool> addAttachment({
    required String taskId,
    required String name,
    required String url,
    required String type,
    required String uploadedBy,
  }) async {
    try {
      final String attachmentId = _uuid.v4();
      final now = DateTime.now();

      final attachment = TaskAttachment(
        id: attachmentId,
        name: name,
        url: url,
        type: type,
        uploadedAt: now,
        uploadedBy: uploadedBy,
      );

      await _tasksCollection.doc(taskId).update({
        'attachments': FieldValue.arrayUnion([attachment.toJson()]),
      });

      return true;
    } catch (e) {
      print('Error adding attachment: $e');
      return false;
    }
  }

  // Add reaction to comment
  Future<bool> addReactionToComment({
    required String taskId,
    required String commentId,
    required String reaction,
  }) async {
    try {
      final task = await getTask(taskId);
      if (task == null) return false;

      final updatedComments = task.comments.map((comment) {
        if (comment.id == commentId) {
          final updatedReactions = List<String>.from(comment.reactions)
            ..add(reaction);
          return TaskComment(
            id: comment.id,
            content: comment.content,
            userId: comment.userId,
            userName: comment.userName,
            userPhotoUrl: comment.userPhotoUrl,
            createdAt: comment.createdAt,
            reactions: updatedReactions,
          );
        }
        return comment;
      }).toList();

      await _tasksCollection.doc(taskId).update({
        'comments': updatedComments.map((c) => c.toJson()).toList(),
      });

      return true;
    } catch (e) {
      print('Error adding reaction: $e');
      return false;
    }
  }

  // Delete task
  Future<bool> deleteTask(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).delete();
      return true;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }

  // Get tasks due soon (for reminders)
  Future<List<TaskModel>> getTasksDueSoon(int hoursThreshold) async {
    try {
      final now = DateTime.now();
      final thresholdTime = now.add(Duration(hours: hoursThreshold));

      final QuerySnapshot snapshot = await _tasksCollection
          .where('dueDate', isGreaterThan: now.toIso8601String())
          .where('dueDate', isLessThan: thresholdTime.toIso8601String())
          .where('status',
              isNotEqualTo: TaskStatus.done.toString().split('.').last)
          .get();

      return snapshot.docs.map((doc) {
        return TaskModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error getting tasks due soon: $e');
      return [];
    }
  }
}
