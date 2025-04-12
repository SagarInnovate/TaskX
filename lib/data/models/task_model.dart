// lib/data/models/task_model.dart
enum TaskPriority { low, medium, high }

enum TaskStatus { todo, inProgress, done }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final String createdBy;
  final String assignedTo;
  final DateTime? dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final List<TaskComment> comments;
  final List<TaskAttachment> attachments;
  final String workspaceId;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.createdBy,
    required this.assignedTo,
    this.dueDate,
    required this.priority,
    required this.status,
    required this.comments,
    required this.attachments,
    required this.workspaceId,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    var commentsList = (json['comments'] as List?)
            ?.map((comment) =>
                TaskComment.fromJson(comment as Map<String, dynamic>))
            .toList() ??
        [];

    var attachmentsList = (json['attachments'] as List?)
            ?.map((attachment) =>
                TaskAttachment.fromJson(attachment as Map<String, dynamic>))
            .toList() ??
        [];

    return TaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      createdBy: json['createdBy'] ?? '',
      assignedTo: json['assignedTo'] ?? '',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString() == 'TaskPriority.${json['priority']}',
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == 'TaskStatus.${json['status']}',
        orElse: () => TaskStatus.todo,
      ),
      comments: commentsList,
      attachments: attachmentsList,
      workspaceId: json['workspaceId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'assignedTo': assignedTo,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'attachments':
          attachments.map((attachment) => attachment.toJson()).toList(),
      'workspaceId': workspaceId,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    String? createdBy,
    String? assignedTo,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    List<TaskComment>? comments,
    List<TaskAttachment>? attachments,
    String? workspaceId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      comments: comments ?? this.comments,
      attachments: attachments ?? this.attachments,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }
}

class TaskComment {
  final String id;
  final String content;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final DateTime createdAt;
  final List<String> reactions;

  TaskComment({
    required this.id,
    required this.content,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.createdAt,
    required this.reactions,
  });

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    return TaskComment(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userPhotoUrl: json['userPhotoUrl'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      reactions:
          (json['reactions'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'createdAt': createdAt.toIso8601String(),
      'reactions': reactions,
    };
  }
}

class TaskAttachment {
  final String id;
  final String name;
  final String url;
  final String type; // file, voice, etc.
  final DateTime uploadedAt;
  final String uploadedBy;

  TaskAttachment({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.uploadedAt,
    required this.uploadedBy,
  });

  factory TaskAttachment.fromJson(Map<String, dynamic> json) {
    return TaskAttachment(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? '',
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'])
          : DateTime.now(),
      uploadedBy: json['uploadedBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'type': type,
      'uploadedAt': uploadedAt.toIso8601String(),
      'uploadedBy': uploadedBy,
    };
  }
}
