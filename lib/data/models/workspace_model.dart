// lib/data/models/workspace_model.dart
import 'user_model.dart';

enum WorkspaceRole { owner, admin, member }

class WorkspaceModel {
  final String id;
  final String name;
  final String description;
  final List<WorkspaceMember> members;
  final DateTime createdAt;
  final String createdBy;

  WorkspaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.createdAt,
    required this.createdBy,
  });

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    var membersList = (json['members'] as List?)
            ?.map((member) =>
                WorkspaceMember.fromJson(member as Map<String, dynamic>))
            .toList() ??
        [];

    return WorkspaceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      members: membersList,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      createdBy: json['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'members': members.map((member) => member.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }
}

class WorkspaceMember {
  final UserModel user;
  final WorkspaceRole role;
  final DateTime joinedAt;

  WorkspaceMember({
    required this.user,
    required this.role,
    required this.joinedAt,
  });

  factory WorkspaceMember.fromJson(Map<String, dynamic> json) {
    return WorkspaceMember(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      role: WorkspaceRole.values.firstWhere(
        (e) => e.toString() == 'WorkspaceRole.${json['role']}',
        orElse: () => WorkspaceRole.member,
      ),
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'role': role.toString().split('.').last,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }
}
